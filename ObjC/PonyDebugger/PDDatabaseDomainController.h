//
//  PDDatabaseDomainController.h
//  PonyDebugger
//
//  Created by HUANG,Shaojun on 7/12/16.
//  Copyright © 2016 yidian. All rights reserved.
//

#import <PonyDebugger/PDObject.h>
#import <PonyDebugger/PDDebugger.h>
#import <PonyDebugger/PDDynamicDebuggerDomain.h>
#import "PDDatabaseDomain.h"
#import "PDDomainController.h"

@interface PDDatabaseDomainController : PDDomainController<PDDatabaseCommandDelegate, PDCommandDelegate>

+ (PDDatabaseDomainController *)defaultInstance;
- (void)enable;


- (void)domain:(PDDatabaseDomain *)domain executeSQLWithDatabaseIdV11:(NSString *)databaseId query:(NSString *)query callback:(void (^)(NSArray *columnNames, NSArray *values, id error))callback;

@end
