//
//  PDInputDomain.m
//  PonyDebugger
//
//  Created by HUANG,Shaojun on 7/16/16.
//  Copyright © 2016 yidian. All rights reserved.
//

#import "PDInputDomain.h"

@implementation PDInputDomain
@dynamic delegate;

+ (NSString *)domainName;
{
    return @"Input";
}


- (void)handleMethodWithName:(NSString *)methodName parameters:(NSDictionary *)params responseCallback:(PDResponseCallback)responseCallback;
{
    if ([methodName isEqualToString:@"enable"] && [self.delegate respondsToSelector:@selector(domain:enableWithCallback:)]) {
        [self.delegate domain:self enableWithCallback:^(id error) {
            responseCallback(nil, error);
        }];
    } else if ([methodName isEqualToString:@"disable"] && [self.delegate respondsToSelector:@selector(domain:disableWithCallback:)]) {
        [self.delegate domain:self disableWithCallback:^(id error) {
            responseCallback(nil, error);
        }];
    } else if ([methodName isEqualToString:@"dispatchMouseEvent"] && [self.delegate respondsToSelector:@selector(domain:dispatchMouseEventWithType:x:y:modifiers:timestamp:button:clickCount:callback:)]) {
        [self.delegate domain:self dispatchMouseEventWithType:[params objectForKey:@"type"] x:[[params objectForKey:@"x"] integerValue] y:[[params objectForKey:@"y"] integerValue] modifiers:[[params objectForKey:@"modifiers"] integerValue]  timestamp:[[params objectForKey:@"timestamp"] integerValue] button:[params objectForKey:@"button"] clickCount:[[params objectForKey:@"clickCount"] integerValue] callback:^(id error) {
            responseCallback(nil, error);
        }];
    }
    else if ([methodName isEqualToString:@"emulateTouchFromMouseEvent"] && [self.delegate respondsToSelector:@selector(domain:emulateTouchFromMouseEventWithType:x:y:deltaX:deltaY:modifiers:timestamp:button:clickCount:callback:)]) {
        [self.delegate domain:self emulateTouchFromMouseEventWithType:[params objectForKey:@"type"] x:[[params objectForKey:@"x"] integerValue] y:[[params objectForKey:@"y"] integerValue] deltaX:[[params objectForKey:@"deltaX"] integerValue] deltaY:[[params objectForKey:@"deltaY"] integerValue] modifiers:[[params objectForKey:@"modifiers"] integerValue]  timestamp:[[params objectForKey:@"timestamp"] integerValue] button:[params objectForKey:@"button"] clickCount:[[params objectForKey:@"clickCount"] integerValue] callback:^(id error) {
            responseCallback(nil, error);
        }];
    }
    else {
        [super handleMethodWithName:methodName parameters:params responseCallback:responseCallback];
    }
}

@end
