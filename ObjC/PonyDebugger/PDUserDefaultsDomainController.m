//
//  PDUserDefaultsDomainController.m
//  PonyDebugger
//
//  Created by Alessandro "Sandro" Calzavara on 26/08/16.
//
//

#import "PDUserDefaultsDomainController.h"
#import "PDRuntimeDomainController.h"
#import "PDRuntimeTypes.h"

#import <Foundation/Foundation.h>

@interface PDUserDefaultsDomainController ()

@end

@implementation PDUserDefaultsDomainController
{
    NSString * _userDefaultsName;
    NSUserDefaults * _userDefaults;
}

@dynamic domain;

#pragma mark - Statics

+ (PDUserDefaultsDomainController *)defaultInstance;
{
    static PDUserDefaultsDomainController *defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[PDUserDefaultsDomainController alloc] init];
    });
    
    return defaultInstance;
}

+ (Class)domainClass;
{
    return [PDIndexedDBDomain class];
}

#pragma mark - Initialization

- (id)init;
{
    self = [super init];
    if (self) {
        _userDefaultsName = @"standardUserDefaults";
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)dealloc;
{
    
}

#pragma mark - PDIndexedDBCommandDelegate

- (void)domain:(PDIndexedDBDomain *)domain requestDatabaseNamesForFrameWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId callback:(void (^)(id))callback;
{
    callback(nil);
    
    [self _broadcastName:requestId];
}

- (void)domain:(PDIndexedDBDomain *)domain requestDatabaseWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId databaseName:(NSString *)databaseName callback:(void (^)(id))callback;
{
    callback(nil);
    
    [self _broadcastStructure:requestId];
}

- (void)domain:(PDIndexedDBDomain *)domain requestDataWithRequestId:(NSNumber *)requestId frameId:(NSString *)frameId databaseName:(NSString *)databaseName objectStoreName:(NSString *)objectStoreName indexName:(NSString *)indexName skipCount:(NSNumber *)skipCount pageSize:(NSNumber *)pageSize keyRange:(PDIndexedDBKeyRange *)keyRange callback:(void (^)(id))callback;
{
    callback(nil);
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    //FIXME keyRange is a NSDictionary, not a PDIndexedDBKeyRange
    NSString * prefix = nil;
    NSString * suffix = nil;
    if (keyRange != nil) {
        NSDictionary * filter = (NSDictionary *)keyRange;
        prefix = [filter objectForKey:@"lower"] != [NSNull null] ? [[filter objectForKey:@"lower"] objectForKey:@"string"] : nil;
        suffix = [filter objectForKey:@"upper"] != [NSNull null] ? [[filter objectForKey:@"upper"] objectForKey:@"string"] : nil;
    }
    
    [self _broadcastContentOf:userDefaults
                    keyPrefix:prefix
                    keySuffix:suffix
                    requestId:requestId];
}

#pragma mark - Private Methods

- (void)_broadcastName:(NSNumber *)requestId
{
    PDIndexedDBSecurityOriginWithDatabaseNames * names = [[PDIndexedDBSecurityOriginWithDatabaseNames alloc] init];
    names.databaseNames = @[ @"NSUserDefaults" ];
    names.securityOrigin= [[NSBundle mainBundle] bundleIdentifier];
    
    [self.domain databaseNamesLoadedWithRequestId:requestId
                  securityOriginWithDatabaseNames:names];
}

- (void)_broadcastStructure:(NSNumber *)requestId
{
    PDIndexedDBObjectStore * objectStore = [[PDIndexedDBObjectStore alloc] init];
    PDIndexedDBKeyPath * keyPath = [[PDIndexedDBKeyPath alloc] init];
    keyPath.type = @"string";
    keyPath.string = @"objectID";
    
    objectStore.keyPath = keyPath;
    objectStore.indexes = @[];
    
    objectStore.autoIncrement = [NSNumber numberWithBool:NO];
    objectStore.name = _userDefaultsName;
    
    PDIndexedDBDatabaseWithObjectStores * db =[[PDIndexedDBDatabaseWithObjectStores alloc] init];
    
    db.name = @"NSUserDefaults";
    db.version = @"N/A";
    db.objectStores = @[ objectStore ];
    
    [self.domain databaseLoadedWithRequestId:requestId
                    databaseWithObjectStores:db];
}

- (void)_broadcastContentOf:(NSUserDefaults *)userDefaults
                  keyPrefix:(NSString *)keyPrefix
                  keySuffix:(NSString *)keySuffix
                  requestId:(NSNumber *)requestId
{
    NSDictionary<NSString *, id> * content = [userDefaults dictionaryRepresentation];
    
    NSMutableArray * dataEntries = [[NSMutableArray alloc] init];

    for (NSString * key in content.allKeys) {
        
        if (keyPrefix != nil && ![key hasPrefix:keyPrefix]) {
            continue;
        }
        if (keySuffix != nil && ![key hasSuffix:keySuffix]) {
            continue;
        }
        
        id object = [content objectForKey:key];
        
        PDIndexedDBDataEntry * dataEntry = [[PDIndexedDBDataEntry alloc] init];
        
        PDIndexedDBKey * primaryKey = [[PDIndexedDBKey alloc] init];
        primaryKey.type = @"string";
        primaryKey.string = key;
        dataEntry.primaryKey = primaryKey;
        dataEntry.key = primaryKey;
        
        PDRuntimeRemoteObject * remoteObject = [[PDRuntimeRemoteObject alloc] init];
        remoteObject.objectId = key;
        
        if ([object isKindOfClass:[NSNumber class]]) {
            
            if (strcmp([object objCType], @encode(BOOL)) == 0) {
                remoteObject.type = @"boolean";
                remoteObject.value = object;
            } else if (strcmp([object objCType], @encode(int)) == 0 || strcmp([object objCType], @encode(NSInteger)) == 0) {
                remoteObject.type = @"int";
                remoteObject.value = object;
            } else if (strcmp([object objCType], @encode(float)) == 0 || strcmp([object objCType], @encode(double)) == 0) {
                remoteObject.type = @"double";
                remoteObject.value = object;
            } else {
                remoteObject.type = @"object";
                remoteObject.objectDescription = [object description];
            }
        } else if ([object isKindOfClass:[NSString class]]) {
            remoteObject.type = @"string";
            remoteObject.objectDescription = object;
        } else {
            remoteObject.type = @"object";
            remoteObject.objectDescription = [object description];
        }
        
        dataEntry.value = remoteObject;
        
        [dataEntries addObject:dataEntry];
    }
    
    [self.domain objectStoreDataLoadedWithRequestId:requestId
                             objectStoreDataEntries:dataEntries
                                            hasMore:@NO];
}

@end
