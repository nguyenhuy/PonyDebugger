//
//  PDSQLiteDomainController.m
//  PonyDebugger
//
//  Created by Alessandro "Sandro" Calzavara on 24/08/16.
//
//

#import "PDSQLiteDomainController.h"
#import "PDDatabaseTypes.h"

#import <sqlite3.h>

@interface PDSQLiteDBWrapper : NSObject

- (nullable instancetype)initWithName:(NSString *)name filePath:(NSString *)filePath;

@property (nonatomic, readonly) NSString * filePath;
@property (nonatomic, readonly) NSString * name;

- (NSArray<NSString *> *)getTablesName;

extern const NSString * QueryColumsKey;
extern const NSString * QueryValuesKey;

- (NSDictionary<NSString *, NSArray *> *)executeQuery:(NSString *)query;

@end


#pragma mark - Controller


@interface PDSQLiteDomainController ()

@property (nonatomic, strong) NSMutableArray<NSString *> * files;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PDSQLiteDBWrapper *>* databases;
@end

@implementation PDSQLiteDomainController

@dynamic domain;

@synthesize databases = _databases;

#pragma mark - Statics

+ (PDSQLiteDomainController *)defaultInstance;
{
    static PDSQLiteDomainController *defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[PDSQLiteDomainController alloc] init];
    });
    
    return defaultInstance;
}

+ (Class)domainClass;
{
    return [PDDatabaseDomain class];
}

#pragma mark - Initialization

- (instancetype)init;
{
    self = [super init];
    if (self) {
        _files = [[NSMutableArray alloc] init];
        _databases = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc;
{
    self.databases = nil;
}

#pragma mark - PDIndexedDBCommandDelegate

- (void)domain:(PDDynamicDebuggerDomain *)domain enableWithCallback:(void (^)(id))callback
{
    for (NSString * filePath in self.files) {
        [self _loadDatabaseFromFile:filePath];
    }
    
    [super domain:domain enableWithCallback:callback];
}

- (void)domain:(PDDynamicDebuggerDomain *)domain disableWithCallback:(void (^)(id))callback
{
    for (NSString * filePath in self.files) {
        [self _unloadDatabaseFromFile:filePath];
    }
    
    [super domain:domain enableWithCallback:callback];
}

- (void)domain:(PDDatabaseDomain *)domain getDatabaseTableNamesWithDatabaseId:(NSString *)databaseId callback:(void (^)(NSArray *, id))callback
{
    PDSQLiteDBWrapper * db = [self.databases objectForKey:databaseId];
    
    NSArray * tables = [db getTablesName];
    
    callback(tables, nil);
}

- (void)domain:(PDDatabaseDomain *)domain executeSQLWithDatabaseId:(NSString *)databaseId query:(NSString *)query callback:(void (^)(NSNumber *, NSNumber *, id))callback
{
    PDSQLiteDBWrapper * db = [self.databases objectForKey:databaseId];
    
    NSNumber * transactionId = [NSNumber numberWithInteger:[[NSDate new] timeIntervalSince1970] * 1000];
    
    NSDictionary * result = [db executeQuery:query];
    NSArray * columns = [result objectForKey:QueryColumsKey];
    NSArray * values = [result objectForKey:QueryValuesKey];
    
    BOOL success = columns != nil && values != nil;
    
    // Order matters!
    // callback first, domain second
    callback([NSNumber numberWithBool:success], transactionId, nil);
    
    if (success) {
        [domain sqlTransactionSucceededWithTransactionId:transactionId columnNames:columns values:values];
    } else {
        [domain sqlTransactionFailedWithTransactionId:transactionId sqlError:@{ /* who knows that to put here */ }];
    }
}


#pragma mark - Public Methods

- (void)addSQLiteFile:(NSString *)file
{
    if ([self.files containsObject:file]) {
        return;
    }
    
    [self.files addObject:file];
    
    if ([self enabled]) {
        [self _loadDatabaseFromFile:file];
    }
}

- (void)removeSQLiteFile:(NSString *)file
{
    if (![self.files containsObject:file]) {
        return;
    }
    
    [self.files removeObject:file];
    
    if ([self enabled]) {
        [self _unloadDatabaseFromFile:file];
    }
}

#pragma mark - Private Methods

- (NSString *)_databaseNameFromFilePath:(NSString *)filePath
{
    return [[filePath lastPathComponent] stringByDeletingPathExtension];
}

- (void)_loadDatabaseFromFile:(NSString *)file
{
    NSString * name = [self _databaseNameFromFilePath:file];
    
    if ([self.databases objectForKey:name] != nil) {
        return;
    }
    
    [self.databases setObject:[[PDSQLiteDBWrapper alloc] initWithName:name filePath:file]
                       forKey:name];
    
    // Notify domain
    PDDatabaseDatabase * db = [[PDDatabaseDatabase alloc] init];
    db.identifier = name;
    db.name = name;
    
    [self.domain addDatabaseWithDatabase:db];
}

- (void)_unloadDatabaseFromFile:(NSString *)file
{
    NSString * name = [self _databaseNameFromFilePath:file];
    
    if ([self.databases objectForKey:name] == nil) {
        return;
    }
    
    [self.databases removeObjectForKey:name];
    
    // Notify domain
    // function not available on domain
}

@end

@implementation PDSQLiteDBWrapper
{
    sqlite3 * sqlite3db;
}

const NSString * QueryColumsKey = @"QueryColumsKey";
const NSString * QueryValuesKey = @"QueryValuesKey";

- (instancetype)initWithName:(NSString *)name filePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        _name = name;
        _filePath = filePath;
    }
    return self;
}

// Open the database.
- (BOOL)_open
{
    int openDatabaseResult = sqlite3_open_v2([self.filePath UTF8String], &sqlite3db, SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_READONLY, NULL);
    
    return openDatabaseResult == SQLITE_OK;
}

// Close the database.
- (BOOL)_close
{
    int result = sqlite3_close(sqlite3db);
    
    return result == SQLITE_OK;
}

// Get all tables name
- (NSArray<NSString *> *)getTablesName
{
    [self _open];
    
    NSMutableArray<NSString *> * names = [[NSMutableArray alloc] init];
    NSString * query = @"SELECT name FROM sqlite_master WHERE type='table';";
    
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(sqlite3db, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char * nameChars = (char *) sqlite3_column_text(statement, 0);
            NSString * name = [[NSString alloc] initWithUTF8String:nameChars];
            
            //NSLog(@"found table: %@", name);
            [names addObject:name];
        }
        
        sqlite3_finalize(statement);
    }
    
    [self _close];
    
    return names;
}

// Return result of a SQL query
- (NSDictionary<NSString *, NSArray *> *)executeQuery:(NSString *)query
{
    [self _open];
    
    NSMutableArray<NSString *> * columns = [[NSMutableArray alloc] init];
    NSMutableArray * values = [[NSMutableArray alloc] init];
    
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(sqlite3db, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
    
        // Get columns
        int columnsCount = sqlite3_column_count(statement);
        
        for (int columnIndex=0; columnIndex < columnsCount; columnIndex++) {
            
            char* nameChars = sqlite3_column_name(statement, columnIndex);
            NSString * name = [[NSString alloc] initWithUTF8String:nameChars];
            
            [columns addObject:name];
        }
        
        // Get values
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            for (int columnIndex=0; columnIndex < columnsCount; columnIndex++) {
                
                sqlite3_value * value = sqlite3_column_value(statement, columnIndex);
                
                int type = sqlite3_value_type(value);
                switch (type) {
                    case SQLITE_INTEGER:
                        [values addObject:[NSNumber numberWithInteger: sqlite3_value_int(value)]];
                        break;
                        
                    case SQLITE_FLOAT:
                        [values addObject:[NSNumber numberWithDouble: sqlite3_value_double(value)]];
                        break;
                        
                    case SQLITE_BLOB:
                        [values addObject:@"BLOB"];
                        break;
                        
                    case SQLITE_NULL:
                        [values addObject:[NSNull null]];
                        break;
                        
                    case SQLITE_TEXT: {
                        char * textChars = (char *) sqlite3_value_text(value);
                        [values addObject:[NSString stringWithUTF8String:textChars]];
                        break;
                    }
                        
                    default:
                        [values addObject:@"???"];
                        break;
                }
                
            }
        }
        
        sqlite3_finalize(statement);
    }
    
    [self _close];
    
    return @{ QueryColumsKey: columns, QueryValuesKey : values };
}

@end
