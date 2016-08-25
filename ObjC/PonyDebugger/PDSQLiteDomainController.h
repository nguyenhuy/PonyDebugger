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

@interface PDSQLiteDomainController : PDDomainController <PDIndexedDBCommandDelegate>

@property (nonatomic, strong) PDIndexedDBDomain *domain;

+ (PDSQLiteDomainController *)defaultInstance;

- (void)addSQLiteFile:(NSString *)filePath;

- (void)removeSQLiteFile:(NSString *)filePath;

@end
