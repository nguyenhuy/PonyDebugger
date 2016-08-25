//
//  PDSQLiteDomainController.h
//  PonyDebugger
//
//  Created by Alessandro "Sandro" Calzavara on 24/08/16.
//
//

#import <PonyDebugger/PDDomainController.h>
#import <PonyDebugger/PDIndexedDBDomain.h>
#import <PonyDebugger/PDIndexedDBTypes.h>

#import <PonyDebugger/PDDatabaseDomain.h>

@interface PDSQLiteDomainController : PDDomainController <PDDatabaseCommandDelegate>

@property (nonatomic, strong) PDDatabaseDomain *domain;

+ (PDSQLiteDomainController *)defaultInstance;

- (void)addSQLiteFile:(NSString *)filePath;

- (void)removeSQLiteFile:(NSString *)filePath;

@end
