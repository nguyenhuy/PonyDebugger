//
//  WVDOMContext.h
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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WVDOMContext : NSObject

/**
 * Returns object key represented by the given string
 *
 * @param keyString The string represents a key
 *
 * @return The key of the string is valid, nil otherwise
 */
+ (NSNumber *)keyFromString:(NSString *)keyString;

/**
 * Stores the given object and returns its associated key
 *
 * @param object The object to be stored
 *
 * @return The object's key
 */
- (NSNumber *)storeObject:(NSObject *)object;

/**
 * Retrieves the object associated with the given key
 *
 * @param key The key to lookup
 *
 * @return The object if found, nil otherwise
 */
- (NSObject *)objectForKey:(NSNumber *)key;

/**
 * Stores the given rect with the given associated key
 *
 * @param rect The rect to be stored
 *
 * @param key The key assocaites with the rect
 */
- (void)setRect:(CGRect)rect forKey:(NSNumber *)key;

/**
 * Retrieves the rect associated with the given key
 *
 * @param key The key to lookup
 *
 * @return The rect if found, CGRectNull otherwise
 */
- (CGRect)rectForKey:(NSNumber *)key;

/**
 * Removes the rect for the given key, if one exists.
 *
 * @param key The key to remove.
 */
- (void)removeRectForKey:(NSNumber *)key;

@end

NS_ASSUME_NONNULL_END
