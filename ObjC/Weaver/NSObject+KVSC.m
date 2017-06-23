//
//  NSObject+KVSC.m
//  PonyDebugger
//
//  Created by Huy Nguyen on 13/6/17.
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import <Weaver/NSObject+KVSC.h>

#import <UIKit/UIKit.h>

@implementation NSObject (KVSC)

- (nullable NSString *)PD_valueStringForKeyPath:(NSString *)keyPath
{
  @try {
    NSValue *value = [self valueForKeyPath:keyPath];
    return [NSObject PD_stringForValue:value atKeyPath:keyPath onObject:self];
  } @catch (NSException *exception) {
    // Continue if valueForKeyPath fails (ie KVC non-compliance)
    return nil;
  }
}

- (void)PD_setValueString:(NSString *)valueString forKeyPath:(NSString *)keyPath
{
  const char *typeEncoding = [NSObject PD_typeEncodingForKeyPath:keyPath onObject:self];
  
  // Note: this is by no means complete...
  // Allow BOOLs to be set with YES/NO
  if (typeEncoding && !strcmp(typeEncoding, @encode(BOOL)) && ([valueString isEqualToString:@"YES"] || [valueString isEqualToString:@"NO"])) {
    BOOL boolValue = [valueString isEqualToString:@"YES"];
    [self setValue:[NSNumber numberWithBool:boolValue] forKeyPath:keyPath];
  } else if (typeEncoding && !strcmp(typeEncoding, @encode(CGPoint))) {
    CGPoint point = CGPointFromString(valueString);
    [self setValue:[NSValue valueWithCGPoint:point] forKeyPath:keyPath];
  } else if (typeEncoding && !strcmp(typeEncoding, @encode(CGSize))) {
    CGSize size = CGSizeFromString(valueString);
    [self setValue:[NSValue valueWithCGSize:size] forKeyPath:keyPath];
  } else if (typeEncoding && !strcmp(typeEncoding, @encode(CGRect))) {
    CGRect rect = CGRectFromString(valueString);
    [self setValue:[NSValue valueWithCGRect:rect] forKeyPath:keyPath];
  } else if (typeEncoding && !strcmp(typeEncoding, @encode(UIEdgeInsets))) {
    UIEdgeInsets insets = UIEdgeInsetsFromString(valueString);
    [self setValue:[NSValue valueWithUIEdgeInsets:insets] forKeyPath:keyPath];
  } else if (typeEncoding && !strcmp(typeEncoding, @encode(id))) {
    id currentValue = [self valueForKeyPath:keyPath];
    if ([currentValue isKindOfClass:[NSString class]]) {
      [self setValue:valueString forKeyPath:keyPath];
    } else if ([currentValue isKindOfClass:[NSAttributedString class]]) {
      [self setValue:[[NSAttributedString alloc] initWithString:valueString] forKeyPath:keyPath];
    } else if ([currentValue isKindOfClass:[NSURL class]]) {
      [self setValue:[NSURL URLWithString:valueString] forKeyPath:keyPath];
    }
  } else {
    NSNumber *number = @([valueString doubleValue]);
    [self setValue:number forKeyPath:keyPath];
  }
}

+ (nullable NSString *)PD_stringForValue:(id)value atKeyPath:(NSString *)keyPath onObject:(id)object
{
  NSString *stringValue = nil;
  const char *typeEncoding = [NSObject PD_typeEncodingForKeyPath:keyPath onObject:object];
  
  if (typeEncoding) {
    // Special structs
    if (!strcmp(typeEncoding,@encode(BOOL))) {
      stringValue = [(id)value boolValue] ? @"YES" : @"NO";
    } else if (!strcmp(typeEncoding,@encode(CGPoint))) {
      stringValue = NSStringFromCGPoint([value CGPointValue]);
    } else if (!strcmp(typeEncoding,@encode(CGSize))) {
      stringValue = NSStringFromCGSize([value CGSizeValue]);
    } else if (!strcmp(typeEncoding,@encode(CGRect))) {
      stringValue = NSStringFromCGRect([value CGRectValue]);
    }
  }
  
  // Boxed numeric primitives
  if (!stringValue && [value isKindOfClass:[NSNumber class]]) {
    stringValue = [(NSNumber *)value stringValue];
    
    // Object types
  } else if (!stringValue && typeEncoding && !strcmp(typeEncoding, @encode(id))) {
    stringValue = [value description];
  }
  
  return stringValue;
}

+ (const char *)PD_typeEncodingForKeyPath:(NSString *)keyPath onObject:(id)object
{
  const char *encoding = NULL;
  NSString *lastKeyPathComponent = nil;
  id targetObject = nil;
  
  // Separate the key path components
  NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
  
  if ([keyPathComponents count] > 1) {
    // Drill down to find the targetObject.key piece that we're interested in.
    NSMutableArray *mutableComponents = [keyPathComponents mutableCopy];
    lastKeyPathComponent = [mutableComponents lastObject];
    [mutableComponents removeLastObject];
    
    NSString *targetKeyPath = [mutableComponents componentsJoinedByString:@"."];
    @try {
      targetObject = [object valueForKeyPath:targetKeyPath];
    } @catch (NSException *exception) {
      // Silently fail for KVC non-compliance
    }
  } else {
    // This is the simple case with no dots. Use the full key and original target object
    lastKeyPathComponent = keyPath;
    targetObject = object;
  }
  
  // Look for a matching set* method to infer the type
  NSString *selectorString = [NSString stringWithFormat:@"set%@:", [lastKeyPathComponent stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[lastKeyPathComponent substringToIndex:1] uppercaseString]]];
  NSMethodSignature *methodSignature = [targetObject methodSignatureForSelector:NSSelectorFromString(selectorString)];
  if (methodSignature) {
    // We don't care about arg0 (self) or arg1 (_cmd)
    encoding = [methodSignature getArgumentTypeAtIndex:2];
  }
  
  // If we didn't find a setter, look for the getter
  // We could be more exhasutive here with KVC conventions, but these two will cover the majority of cases
  if (!encoding) {
    NSMethodSignature *getterSignature = [targetObject methodSignatureForSelector:NSSelectorFromString(lastKeyPathComponent)];
    encoding = [getterSignature methodReturnType];
  }
  
  return encoding;
}

@end
