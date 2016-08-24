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

@interface PDSQLiteDomainController ()

@property (nonatomic, strong) NSNumber *rootFrameRequestID;
@property (nonatomic, strong) NSMutableArray<NSString *>* files;
@end

@implementation PDSQLiteDomainController

@dynamic domain;

@synthesize rootFrameRequestID = _rootFrameRequestID;
@synthesize files = _files;

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
        _files = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc;
{
    self.rootFrameRequestID = nil;
}

#pragma mark - PDIndexedDBCommandDelegate

- (void)domain:(PDIndexedDBDomain *)domain requestDatabaseNamesForFrameWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId callback:(void (^)(id))callback;
{
    callback(nil);
    
    self.rootFrameRequestID = requestId;
    [self _broadcastDatabaseNames];
}

- (void)domain:(PDIndexedDBDomain *)domain requestDatabaseWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId databaseName:(NSString *)databaseName callback:(void (^)(id))callback;
{
    callback(nil);
    
    [self _broadcastDatabase:[self _databaseForName:databaseName]
                   requestId:requestId];
}

- (void)domain:(PDIndexedDBDomain *)domain requestDataWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId databaseName:(NSString *)databaseName objectStoreName:(NSString *)objectStoreName indexName:(NSString *)indexName skipCount:(NSNumber *)skipCount pageSize:(NSNumber *)pageSize keyRange:(PDIndexedDBKeyRange *)keyRange callback:(void (^)(id))callback;
{
    callback(nil);
    
    //TODO
    
    NSArray * dataEntries = [[NSArray alloc] init];
    
    NSNumber * hasMore = [NSNumber numberWithBool:NO];
    
    [self.domain objectStoreDataLoadedWithRequestId:requestId
                             objectStoreDataEntries:dataEntries
                                            hasMore:hasMore];
}

#pragma mark - Public Methods

- (void)addSQLiteFile:(NSString *)file
{
    if ([self.files containsObject:file]) {
        return;
    }
    
    [self.files addObject:file];
    
    [self _broadcastDatabaseNames];
}

- (void)removeSQLiteFile:(NSString *)file
{
    if (![self.files containsObject:file]) {
        return;
    }
    
    [self.files removeObject:file];
    
    [self _broadcastDatabaseNames];
}

#pragma mark - Private Methods

- (id)_databaseForName:(NSString *)name
{
    return nil;
}

- (NSString *)_databaseName:(NSString *)filePath
{
    return [filePath lastPathComponent];
}

- (void)_broadcastDatabaseNames
{
    NSMutableArray *dbNames = [[NSMutableArray alloc] initWithCapacity:_files.count];
    
    [self.files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * filePath = obj;
        
        [dbNames addObject:[self _databaseName:filePath]];
    }];
    
    PDIndexedDBSecurityOriginWithDatabaseNames * databaseNames = [[PDIndexedDBSecurityOriginWithDatabaseNames alloc] init];
    
    databaseNames.databaseNames = dbNames;
    databaseNames.securityOrigin = [[NSBundle mainBundle] bundleIdentifier];
    
    [self.domain databaseNamesLoadedWithRequestId:_rootFrameRequestID securityOriginWithDatabaseNames:databaseNames];
}

// Emit the database structure
- (void)_broadcastDatabase:(NSString *)database requestId:(NSNumber *)requestId
{
    // objectStore (PDIndexedDBObjectStore) -> Table
    // index (PDIndexedDBObjectStoreIndex) -> Column
    // keyPath (PDIndexedDBKeyPath) -> ???
    
    NSMutableArray * objectStores = [[NSMutableArray alloc] init];
    
    PDIndexedDBDatabaseWithObjectStores * db = [[PDIndexedDBDatabaseWithObjectStores alloc] init];
    
    db.name = [self _databaseName:database];
    
    // Episodes ?
    
    PDIndexedDBKeyPath * guidKeyPath1 = [[PDIndexedDBKeyPath alloc] init];
    guidKeyPath1.type = @"string";
    guidKeyPath1.string = @"episode_id";
    
    PDIndexedDBObjectStoreIndex *index1 = [[PDIndexedDBObjectStoreIndex alloc] init];
    index1.name = @"episode_id";
    index1.keyPath = guidKeyPath1;
    index1.unique = [NSNumber numberWithBool:YES];
    index1.multiEntry = [NSNumber numberWithBool:NO];
    
    PDIndexedDBKeyPath * guidKeyPath2 = [[PDIndexedDBKeyPath alloc] init];
    guidKeyPath2.type = @"string";
    guidKeyPath2.string = @"show_id";
    
    PDIndexedDBObjectStoreIndex *index2 = [[PDIndexedDBObjectStoreIndex alloc] init];
    index2.name = @"show_id";
    index2.keyPath = guidKeyPath2;
    index2.unique = [NSNumber numberWithBool:NO];
    index2.multiEntry = [NSNumber numberWithBool:NO];

    PDIndexedDBKeyPath * keyPath = [[PDIndexedDBKeyPath alloc] init];
    keyPath.type = @"string";
    keyPath.string = @"objectID";
    
    PDIndexedDBObjectStore * objectStore = [[PDIndexedDBObjectStore alloc] init];
    objectStore.keyPath = keyPath;
    objectStore.indexes = @[ index1, index2 ];
    objectStore.autoIncrement = [NSNumber numberWithBool:NO];
    objectStore.name = @"Episodes";

    [objectStores addObject:objectStore];

    db.version = @"N/A";
    db.objectStores = objectStores;

    [self.domain databaseLoadedWithRequestId:requestId
                    databaseWithObjectStores:db];
}

@end
