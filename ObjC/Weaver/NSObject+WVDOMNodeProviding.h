//
//  NSObject+WVDOMNodeProviding.h
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASBaseDefines.h>
#import <AsyncDisplayKit/ASDimensionInternal.h>

NS_ASSUME_NONNULL_BEGIN

@class PDDOMNode, WVDOMContext;

@interface NSObject (PDDOMNodeProviding)

- (PDDOMNode *)wv_generateDOMNodeWithContext:(WVDOMContext *)context;
- (CGRect)wv_frameInWindow;
- (NSArray *)wv_children;

@end

NS_ASSUME_NONNULL_END

#endif
