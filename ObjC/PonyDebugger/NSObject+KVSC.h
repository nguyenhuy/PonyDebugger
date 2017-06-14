//
//  NSObject+KVSC.h
//  PonyDebugger
//
//  Created by Huy Nguyen on 13/6/17.
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVSC)

+ (nullable NSString *)PD_stringForValue:(id)value atKeyPath:(NSString *)keyPath onObject:(id)object;

- (nullable NSString *)PD_valueStringForKeyPath:(NSString *)keyPath;

- (void)PD_setValueString:(NSString *)valueString forKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
