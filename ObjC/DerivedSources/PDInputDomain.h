//
//  PDInputDomain.h
//  PonyDebugger
//
//  Created by HUANG,Shaojun on 7/16/16.
//  Copyright © 2016 yidian. All rights reserved.
//

#import <PonyDebugger/PDDynamicDebuggerDomain.h>

@class PDInputDomain;

@protocol PDInputCommandDelegate <PDCommandDelegate>
@optional

- (void)domain:(PDInputDomain *)domain dispatchKeyEventWithType:(NSString *)type modifiers:(NSInteger)modifiers timestamp:(NSTimeInterval)timestamp text:(NSString*)text unmodifiedText:(NSString*)unmodifiedText keyIdentifier:(NSString*)keyIdentifier code:(NSString*)code key:(NSString*)key windowsVirtualKeyCode:(NSInteger)windowsVirtualKeyCode nativeVirtualKeyCode:(NSInteger)nativeVirtualKeyCode autoRepeat:(BOOL)autoRepeat isKeypad:(BOOL)isKeypad isSystemKey:(BOOL)isSystemKey callback:(void (^)(id error))callback;

- (void)domain:(PDInputDomain *)domain dispatchMouseEventWithType:(NSString *)type x:(NSInteger)x y:(NSInteger)y modifiers:(NSInteger)modifiers timestamp:(NSTimeInterval)timestamp button:(NSString*)button clickCount:(NSInteger)clickCount callback:(void (^)(id error))callback;

- (void)domain:(PDInputDomain *)domain emulateTouchFromMouseEventWithType:(NSString *)type x:(NSInteger)x y:(NSInteger)y deltaX:(NSInteger)deltaX deltaY:(NSInteger)deltaY modifiers:(NSInteger)modifiers timestamp:(NSTimeInterval)timestamp button:(NSString*)button clickCount:(NSInteger)clickCount callback:(void (^)(id error))callback;
@end

@interface PDInputDomain : PDDynamicDebuggerDomain

@property (nonatomic, assign) id <PDInputCommandDelegate, PDCommandDelegate> delegate;

@end
