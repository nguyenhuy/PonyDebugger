//
//  WVDOMContext.m
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <Weaver/WVDOMContext.h>

#import <UIKit/UIKit.h>

__attribute__((const))
static NSUInteger WVRectSize(const void *ptr)
{
  return sizeof(CGRect);
}

@implementation WVDOMContext {
  NSInteger _counter;
  
  NSMapTable<NSNumber *, NSObject *> *_objectTable;
  NSMapTable<NSNumber *, id> *_rectTable;
}

+ (NSMapTable<NSNumber *, id> *)newRectTable
{
  NSPointerFunctions *strongObjectPointerFuncs = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality];
  NSPointerFunctions *cgRectFuncs = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStructPersonality | NSPointerFunctionsCopyIn | NSPointerFunctionsMallocMemory];
  cgRectFuncs.sizeFunction = &WVRectSize;
  
  return [[NSMapTable alloc] initWithKeyPointerFunctions:strongObjectPointerFuncs valuePointerFunctions:cgRectFuncs capacity:0];
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _objectTable = [NSMapTable strongToStrongObjectsMapTable];
    _rectTable = [WVDOMContext newRectTable];
  }
  return self;
}

+ (NSNumber *)keyFromString:(NSString *)keyString
{
  return @([keyString integerValue]);
}

- (NSNumber *)storeObject:(NSObject *)object
{
  NSNumber *key = @(_counter++);
  [_objectTable setObject:object forKey:key];
  return key;
}

- (NSObject *)objectForKey:(NSNumber *)key
{
  return [_objectTable objectForKey:key];
}

- (void)setRect:(CGRect)rect forKey:(NSNumber *)key
{
  __unsafe_unretained id obj = (__bridge id)&rect;
  [_rectTable setObject:obj forKey:key];
}

- (CGRect)rectForKey:(NSNumber *)key
{
  CGRect *ptr = (__bridge CGRect *)[_rectTable objectForKey:key];
  if (ptr == NULL) {
    return CGRectNull;
  }
  return *ptr;
}

- (void)removeRectForKey:(NSNumber *)key
{
  [_rectTable removeObjectForKey:key];
}

@end
