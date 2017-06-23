//
//  WVDebugger.m
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Weaver/WVDebugger.h>
#import <Weaver/WVElementDomainController.h>
#import <Weaver/WVElementPropsDomainController.h>

@implementation WVDebugger

+ (WVDebugger *)defaultInstance
{
  static dispatch_once_t onceToken;
  static WVDebugger *defaultInstance = nil;
  dispatch_once(&onceToken, ^{
    defaultInstance = [[[self class] alloc] init];
  });
  
  return defaultInstance;
}

- (void)enableLayoutElementDebuggingWithApplication:(UIApplication *)application
{
  WVElementDomainController *elementController = [WVElementDomainController defaultInstance];
  [self addController:elementController];
  [elementController startMonitoringWithApplication:application];
  
  WVElementPropsDomainController *elementPropsController = [[WVElementPropsDomainController alloc] init];
  elementPropsController.dataSource = elementController;
  [self addController:elementPropsController];
}

@end

#endif // AS_TEXTURE_DEBUGGER
