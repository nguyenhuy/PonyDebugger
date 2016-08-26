//
//  PDUserDefaultsDomainController.m
//  PonyDebugger
//
//  Created by Alessandro "Sandro" Calzavara on 26/08/16.
//
//

#import "PDUserDefaultsDomainController.h"
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
    
    [self _broadcastContentOf:userDefaults
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

- (void)_broadcastContentOf:(NSUserDefaults *)userDefaults requestId:(NSNumber *)requestId
{
    
}

@end
