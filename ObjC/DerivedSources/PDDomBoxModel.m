//
//  PDDomBoxModel.m
//  PonyDebugger
//
//  Created by HUANG,Shaojun on 7/16/16.
//  Copyright © 2016 yidian. All rights reserved.
//

#import "PDDomBoxModel.h"

@implementation PDDomBoxModel

@dynamic content;
@dynamic padding;
@dynamic border;
@dynamic margin;
@dynamic width;
@dynamic height;

+ (NSDictionary *)keysToEncode;
{
    static NSDictionary *mappings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                    @"content",@"content",
                    @"padding",@"padding",
                    @"border",@"border",
                    @"margin",@"margin",
                    @"width",@"width",
                    @"height",@"height",
                    nil];
    });
    
    return mappings;
}

@end
