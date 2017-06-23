//
//  WVElementDomainController.h
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Weaver/WVElementPropsDomainController.h>

#import <Weaver/PDDOMDomain.h>
#import <Weaver/PDDomainController.h>

#import <UIKit/UIKit.h>

@class WVDOMContext;

NS_ASSUME_NONNULL_BEGIN

@interface WVElementDomainController : PDDomainController <PDDOMCommandDelegate, WVElementPropsDomainControllerDataSource>

@property (nonatomic, strong) PDDOMDomain *domain;
@property (nonatomic, readonly) WVDOMContext *context;

+ (WVElementDomainController *)defaultInstance;

- (void)startMonitoringWithApplication:(UIApplication *)application;

@end

NS_ASSUME_NONNULL_END
