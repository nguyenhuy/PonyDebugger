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
    NSUserDefaults * _userDefaultsObj;
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
        _userDefaultsObj = [NSUserDefaults standardUserDefaults];
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
    
    //FIXME keyRange is a NSDictionary, not a PDIndexedDBKeyRange
    NSString * prefix = nil;
    NSString * suffix = nil;
    if ([keyRange isKindOfClass:[PDIndexedDBKeyRange class]]) {
        prefix = keyRange.lower.string;
        suffix = keyRange.upper.string;
    }
    else if ([keyRange isKindOfClass:[NSDictionary class]]) {
        NSDictionary * filter = (NSDictionary *)keyRange;
        prefix = [filter objectForKey:@"lower"] != [NSNull null] ? [[filter objectForKey:@"lower"] objectForKey:@"string"] : nil;
        suffix = [filter objectForKey:@"upper"] != [NSNull null] ? [[filter objectForKey:@"upper"] objectForKey:@"string"] : nil;
    }
    
    [self _broadcastContentOf:_userDefaultsObj
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
        
        NSString * lowerCaseKey = [key lowercaseString];
        if (keyPrefix != nil && ![lowerCaseKey hasPrefix:[keyPrefix lowercaseString]]) {
            continue;
        }
        if (keySuffix != nil && ![lowerCaseKey hasSuffix:[keySuffix lowercaseString]]) {
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
        remoteObject.objectId = [[PDRuntimeDomainController defaultInstance] registerAndGetKeyForObject:object];
        
        // types are object
        // subtype are array, date
        
        if ([object isKindOfClass:[NSNumber class]]) {

            remoteObject.type = @"number";
            remoteObject.objectDescription = [object description];
            
        } else if ([object isKindOfClass:[NSString class]]) {
            
            remoteObject.type = @"string";
            remoteObject.objectDescription = object;

        } else if ([object isKindOfClass:[NSDate class]]) {
            
            remoteObject.type = @"date";
            remoteObject.objectDescription = [object description];
            
        } else if ([object isKindOfClass:[NSArray class]]) {
            
            remoteObject.type = @"array";
            remoteObject.objectDescription = [object description];
            
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
