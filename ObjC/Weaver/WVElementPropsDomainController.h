//
//  WVElementPropsDomainController.h
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Weaver/PDCSSDomain.h>
#import <Weaver/PDDomainController.h>

@class WVElementPropsDomainController, WVDOMContext;

NS_ASSUME_NONNULL_BEGIN

@protocol WVElementPropsDomainControllerDataSource <NSObject>

- (WVDOMContext *)contextForElementPropsDomainController:(WVElementPropsDomainController *)controller;

@end

@interface WVElementPropsDomainController : PDDomainController <PDCSSCommandDelegate>

@property (nonatomic, strong) PDCSSDomain *domain;
@property (nonatomic, weak) id<WVElementPropsDomainControllerDataSource> dataSource;

+ (WVElementPropsDomainController *)defaultInstance;

@end

NS_ASSUME_NONNULL_END
