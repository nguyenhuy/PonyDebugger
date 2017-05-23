//
//  PDUserDefaultsDomainController.h
//  PonyDebugger
//
//  Created by Alessandro "Sandro" Calzavara on 26/08/16.
//
//

#import <PonyDebugger/PDDomainController.h>
#import <PonyDebugger/PDIndexedDBDomain.h>
#import <PonyDebugger/PDIndexedDBTypes.h>

@class NSUserDefaults;

@interface PDUserDefaultsDomainController : PDDomainController <PDIndexedDBCommandDelegate>

@property (nonatomic, strong) PDIndexedDBDomain *domain;

+ (PDUserDefaultsDomainController *)defaultInstance;

@end
