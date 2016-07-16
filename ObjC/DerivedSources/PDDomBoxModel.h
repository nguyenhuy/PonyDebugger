//
//  PDDomBoxModel.h
//  PonyDebugger
//
//  Created by HUANG,Shaojun on 7/16/16.
//  Copyright © 2016 yidian. All rights reserved.
//

#import "PDObject.h"

@interface PDDomBoxModel : PDObject

@property (nonatomic, strong) NSArray/* quad An array of quad vertices, x immediately followed by y for each point, points clock-wise.*/ *content;
@property (nonatomic, strong) NSArray/* quad An array of quad vertices, x immediately followed by y for each point, points clock-wise.*/ *padding;
@property (nonatomic, strong) NSArray/* quad An array of quad vertices, x immediately followed by y for each point, points clock-wise.*/ *border;
@property (nonatomic, strong) NSArray/* quad An array of quad vertices, x immediately followed by y for each point, points clock-wise.*/ *margin;

@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;

@end
