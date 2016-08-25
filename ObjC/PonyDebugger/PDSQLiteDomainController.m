//
//  PDSQLiteDomainController.m
//  PonyDebugger
//
//  Created by Alessandro "Sandro" Calzavara on 24/08/16.
//
//

#import "PDSQLiteDomainController.h"
#import "PDRuntimeDomainController.h"
#import "PDIndexedDBTypes.h"
#import "PDRuntimeTypes.h"

#import <sqlite3.h>

@interface SQLiteUtil : NSObject

+ (nullable NSString *)typeDescription:(int)typeInt;
+ (void)debugStatement:(sqlite3_stmt *)statement;

@end

@interface PDSQLiteDatabase : NSObject

- (nullable instancetype)initWithName:(NSString *)name filePath:(NSString *)filePath;

@property (nonatomic, readonly) NSString * filePath;
@property (nonatomic, readonly) NSString * name;

- (NSArray *)getTables;

@end

#pragma mark - Controller


@interface PDSQLiteDomainController ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, PDSQLiteDatabase *>* databases;
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
    return [PDIndexedDBDomain class];
}

#pragma mark - Initialization

- (instancetype)init;
{
    self = [super init];
    if (self) {
        _databases = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc;
{
    self.databases = nil;
}

#pragma mark - PDIndexedDBCommandDelegate

- (void)domain:(PDIndexedDBDomain *)domain requestDatabaseNamesForFrameWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId callback:(void (^)(id))callback
{
    [self _broadcastDatabaseNamesWithRequestId:requestId];
    
    callback(nil);
}

- (void)domain:(PDIndexedDBDomain *)domain requestDatabaseWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId databaseName:(NSString *)databaseName callback:(void (^)(id))callback;
{
    [self _broadcastDatabase:[self.databases objectForKey:databaseName]
                   requestId:requestId];
    
    callback(nil);
}

- (void)domain:(PDIndexedDBDomain *)domain requestDataWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId databaseName:(NSString *)databaseName objectStoreName:(NSString *)objectStoreName indexName:(NSString *)indexName skipCount:(NSNumber *)skipCount pageSize:(NSNumber *)pageSize keyRange:(PDIndexedDBKeyRange *)keyRange callback:(void (^)(id))callback;
{
    NSLog(@"requestData");
    NSLog(@"databaseName: %@", databaseName);
    NSLog(@"objectStoreName: %@", objectStoreName);
    NSLog(@"indexName: %@", indexName);
    NSLog(@"skipCount: %@", skipCount);
    NSLog(@"pageSize: %@", pageSize);
    NSLog(@"keyRange: %@", keyRange);
    
    
    //TODO
    
    NSArray * dataEntries = [[NSArray alloc] init];
    
    NSNumber * hasMore = [NSNumber numberWithBool:NO];
    
    [self.domain objectStoreDataLoadedWithRequestId:requestId
                             objectStoreDataEntries:dataEntries
                                            hasMore:hasMore];
    
    callback(nil);
}

#pragma mark - Public Methods

- (void)addSQLiteFile:(NSString *)file
{
    NSString * name = [self _databaseNameFromFilePath:file];
    
    if ([self.databases objectForKey:name] != nil) {
        return;
    }
    
    [self.databases setObject:[self _createDatabaseWithName:name filePath:file]
                       forKey:name];
}

- (void)removeSQLiteFile:(NSString *)file
{
    NSString * name = [self _databaseNameFromFilePath:file];
    
    if ([self.databases objectForKey:name] == nil) {
        return;
    }
    
    [self.databases removeObjectForKey:name];
}

#pragma mark - Private Methods

- (NSString *)_databaseNameFromFilePath:(NSString *)filePath
{
    return [[filePath lastPathComponent] stringByDeletingPathExtension];
}

- (nullable PDSQLiteDatabase *)_createDatabaseWithName:(NSString *)name filePath:(NSString *)filePath
{
    return [[PDSQLiteDatabase alloc] initWithName:name filePath:filePath];
}

- (void)_broadcastDatabaseNamesWithRequestId:(NSNumber *)requestId
{
    PDIndexedDBSecurityOriginWithDatabaseNames * databaseNames = [[PDIndexedDBSecurityOriginWithDatabaseNames alloc] init];
    
    databaseNames.databaseNames = self.databases.allKeys;
    databaseNames.securityOrigin = [[NSBundle mainBundle] bundleIdentifier];
    
    [self.domain databaseNamesLoadedWithRequestId:requestId
                  securityOriginWithDatabaseNames:databaseNames];
}

// Emit the database structure
- (void)_broadcastDatabase:(PDSQLiteDatabase *)database requestId:(NSNumber *)requestId
{
    // objectStore (PDIndexedDBObjectStore) -> Table
    // index (PDIndexedDBObjectStoreIndex) -> Column
    // keyPath (PDIndexedDBKeyPath) -> ???
    
    PDIndexedDBDatabaseWithObjectStores * db = [[PDIndexedDBDatabaseWithObjectStores alloc] init];
    db.name = database.name;
    db.version = @"N/A";
    db.objectStores = [database getTables];
    
    [self.domain databaseLoadedWithRequestId:requestId
                    databaseWithObjectStores:db];
}

@end

@implementation PDSQLiteDatabase
{
    sqlite3 * sqlite3db;
}

- (instancetype)initWithName:(NSString *)name filePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        _name = name;
        _filePath = filePath;
    }
    return self;
}

- (BOOL)open
{
    // Open the database.
    int openDatabaseResult = sqlite3_open_v2([self.filePath UTF8String], &sqlite3db, SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_READONLY, NULL);
    
    return openDatabaseResult == SQLITE_OK;
}

- (BOOL)close
{
    // Close the database.
    int result = sqlite3_close(sqlite3db);
    
    return result == SQLITE_OK;
}

- (NSArray<NSString *> *)_getTablesName
{
    NSMutableArray<NSString *> * names = [[NSMutableArray alloc] init];
    NSString * query = @"SELECT name FROM sqlite_master WHERE type='table';";
    
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(sqlite3db, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char * nameChars = (char *) sqlite3_column_text(statement, 0);
            NSString * name = [[NSString alloc] initWithUTF8String:nameChars];
            
            NSLog(@"found table: %@", name);
            [names addObject:name];
        }
        
        sqlite3_finalize(statement);
    }
    
    return names;
}

- (NSArray<PDIndexedDBObjectStoreIndex *> *)_getTableColumns:(NSString *)tableName
{
    NSLog(@"getting columns from table %@", tableName);
    
    NSMutableArray<PDIndexedDBObjectStoreIndex *> * columns = [[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"pragma table_info('%@');", tableName];
    
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(sqlite3db, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK) {
        
        [SQLiteUtil debugStatement:statement];
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char * nameChars = (char *) sqlite3_column_text(statement, 1);
            NSString * name = [[NSString alloc] initWithUTF8String:nameChars];
            
            int typeInt = sqlite3_column_type(statement, 2);
            NSString * type = [SQLiteUtil typeDescription:typeInt];
            
            int primaryInt = sqlite3_column_int(statement, 5);
            BOOL isPrimary = primaryInt > 0;
            
            NSLog(@"found column: %@ type: %d %@ primary: %d", name, typeInt, type, primaryInt);
            
            PDIndexedDBKeyPath * columnKeyPath = [[PDIndexedDBKeyPath alloc] init];
            columnKeyPath.type = type;
            columnKeyPath.string = name;
            
            PDIndexedDBObjectStoreIndex * column = [[PDIndexedDBObjectStoreIndex alloc] init];
            column.name = name;
            column.keyPath = columnKeyPath;
            column.unique = [NSNumber numberWithBool:isPrimary];
            column.multiEntry = [NSNumber numberWithBool:YES];
            
            [columns addObject:column];
        }
        
        sqlite3_finalize(statement);
    }
    
    return columns;
}

- (NSArray<PDIndexedDBObjectStore *> *)getTables
{
    [self open];
    
    NSMutableArray<PDIndexedDBObjectStore *> * tables = [[NSMutableArray alloc] init];
    
    // Step 1: fetch all table names
    NSArray<NSString *> * tablesName = [self _getTablesName];
    
    // Step 2: fetch fields for each table name and build the final structure
    for (NSString * tableName in tablesName) {
        
        PDIndexedDBKeyPath * tableKeyPath = [[PDIndexedDBKeyPath alloc] init];
        tableKeyPath.type = @"string";
        tableKeyPath.string = tableName;
        
        PDIndexedDBObjectStore * table = [[PDIndexedDBObjectStore alloc] init];
        table.keyPath = tableKeyPath;
        table.autoIncrement = [NSNumber numberWithBool:NO];
        table.name = tableName;
        table.indexes = [self _getTableColumns:tableName];
        
        [tables addObject:table];
    }
    
    [self close];
    
    return tables;
}

@end

@implementation SQLiteUtil

+ (nullable NSString *)typeDescription:(int)typeInt
{
    switch (typeInt) {
        case SQLITE_INTEGER:
            return @"integer";
            break;
            
        case SQLITE_FLOAT:
            return @"float";
            break;
            
        case SQLITE_BLOB:
            return @"blob";
            break;
            
        case SQLITE_NULL:
            return @"null";
            break;
            
        case SQLITE_TEXT:
            return @"text";
            break;
            
        default:
            return nil;
            break;
    }
}

+ (void)debugStatement:(sqlite3_stmt *)statement
{
    // Print structure
    int columnsCount = sqlite3_column_count(statement);
    
    for (int columnIndex=0; columnIndex < columnsCount; columnIndex++) {
        
        char* nameChars = sqlite3_column_name(statement, columnIndex);
        NSString * name = [[NSString alloc] initWithUTF8String:nameChars];
        
        int type = sqlite3_column_type(statement, columnIndex);
        
        NSLog(@"column %d: %@ (type: %d %@)", columnIndex, name, type, [self typeDescription:type]);
    }
    
    // Print content
    while (sqlite3_step(statement) == SQLITE_ROW) {
        
        NSMutableArray<NSString *>* content = [[NSMutableArray alloc] init];
        
        for (int columnIndex=0; columnIndex < columnsCount; columnIndex++) {
            
            sqlite3_value * value = sqlite3_column_value(statement, columnIndex);
            
            int type = sqlite3_value_type(value);
            switch (type) {
                case SQLITE_INTEGER:
                    [content addObject:[NSString stringWithFormat:@"%d", sqlite3_value_int(value)]];
                    break;
                    
                case SQLITE_FLOAT:
                    [content addObject:[NSString stringWithFormat:@"%f", sqlite3_value_double(value)]];
                    break;
                    
                case SQLITE_BLOB:
                    [content addObject:@"BLOB"];
                    break;
                    
                case SQLITE_NULL:
                    [content addObject:@"NULL"];
                    break;
                    
                case SQLITE_TEXT: {
                    char * textChars = (char *) sqlite3_value_text(value);
                    [content addObject:[NSString stringWithUTF8String:textChars]];
                    break;
                }
                    
                default:
                    [content addObject:@"???"];
                    break;
            }
            
        }
        
        NSLog(@"row %@", content);
        
    }
    
    sqlite3_reset(statement);
}

@end
