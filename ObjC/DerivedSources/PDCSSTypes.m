//
//  PDCSSTypes.m
//  PonyDebuggerDerivedSources
//
//  Generated on 8/23/12
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import "PDCSSTypes.h"

@implementation PDCSSPseudoIdRules

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"pseudoId",@"pseudoId",
                @"rules",@"rules",
                nil];
  });
  
  return mappings;
}

@dynamic pseudoId, rules;

@end

@implementation PDCSSSourceRange

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"startLine",@"startLine",
                @"startColumn",@"startColumn",
                @"endLine",@"endLine",
                @"endColumn",@"endColumn",
                nil];
  });
  
  return mappings;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    // These tell the frontend where in the stylesheet a certain style
    // is located. Since we don't have stylesheets, this is all 0.
    // We need this because CSS fields are not editable unless
    // the range is provided.
    // Credit: https://chromium.googlesource.com/chromium/src.git/+/27d1ff58a6ae0788d6f9d776d3c593d853e919aa/ash/devtools/ash_devtools_css_agent.cc#25
    self.startLine = @(0);
    self.startColumn = @(0);
    self.endLine = @(0);
    self.endColumn = @(0);
  }
  return self;
}

@dynamic startLine, startColumn, endLine, endColumn;

@end

@implementation PDCSSStyle

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"styleSheetId",@"styleSheetId",
                @"cssProperties",@"cssProperties",
                @"shorthandEntries",@"shorthandEntries",
                @"cssText",@"cssText",
                @"range",@"range",
                nil];
  });
  
  return mappings;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.range = [[PDCSSSourceRange alloc] init];
  }
  return self;
}

@dynamic styleSheetId, cssProperties, shorthandEntries, cssText, range;

@end

@implementation PDCSSInheritedStyleEntry

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"inlineStyle",@"inlineStyle",
                @"matchedCSSRules",@"matchedCSSRules",
                nil];
  });
  
  return mappings;
}

@dynamic inlineStyle, matchedCSSRules;

@end

@implementation PDCSSStyleAttribute

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"name",@"name",
                @"style",@"style",
                nil];
  });
  
  return mappings;
}

@dynamic name, style;

@end

@implementation PDCSSStyleSheetHeader

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"styleSheetId",@"styleSheetId",
                @"frameId",@"frameId",
                @"sourceURL",@"sourceURL",
                @"origin",@"origin",
                @"title",@"title",
                @"disabled",@"disabled",
                nil];
  });
  
  return mappings;
}

@dynamic styleSheetId, frameId, sourceURL, origin, title, disabled;

@end

@implementation PDCSSStyleSheetBody

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"styleSheetId",@"styleSheetId",
                @"rules",@"rules",
                @"text",@"text",
                nil];
  });
  
  return mappings;
}

@dynamic styleSheetId, rules, text;

@end

@implementation PDCSSValue

+ (instancetype)valueWithText:(NSString *)text
{
  PDCSSValue *value = [[PDCSSValue alloc] init];
  value.text = text;
  return value;
}

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"text",@"text",
                @"range",@"range",
                nil];
  });
  
  return mappings;
}

@dynamic text, range;

@end

@implementation PDCSSSelectorList

+ (instancetype)selectorListWithSelectors:(NSArray<PDCSSValue *> *)selectors
{
  PDCSSSelectorList *list = [[PDCSSSelectorList alloc] init];
  list.selectors = selectors;
  return list;
}

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"selectors",@"selectors",
                @"text",@"text",
                nil];
  });
  
  return mappings;
}

@dynamic selectors, text;

@end

@implementation PDCSSMediaQueryExpression

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"value",@"value",
                @"unit",@"unit",
                @"feature",@"feature",
                @"valueRange",@"valueRange",
                @"computedLength",@"computedLength",
                nil];
  });
  
  return mappings;
}

@dynamic value, unit, feature, valueRange, computedLength;

@end

@implementation PDCSSMediaQuery

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"expressions",@"expressions",
                @"active",@"active",
                nil];
  });
  
  return mappings;
}

@dynamic expressions, active;

@end

@implementation PDCSSMedia

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"text",@"text",
                @"source",@"source",
                @"sourceURL",@"sourceURL",
                @"range",@"range",
                @"parentStyleSheetId",@"parentStyleSheetId",
                @"mediaList",@"mediaList",
                nil];
  });
  
  return mappings;
}

@dynamic text, source, sourceURL, range, parentStyleSheetId, mediaList;

@end

@implementation PDCSSRule

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"styleSheetId",@"styleSheetId",
                @"selectorList",@"selectorList",
                @"origin",@"origin",
                @"style",@"style",
                @"media",@"media",
                nil];
  });
  
  return mappings;
}

@dynamic styleSheetId, selectorList, origin, style;

@end

@implementation PDCSSRuleMatch

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"rule",@"rule",
                @"matchingSelectors",@"matchingSelectors",
                nil];
  });
  
  return mappings;
}

@dynamic rule, matchingSelectors;

@end

@implementation PDCSSShorthandEntry

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"name",@"name",
                @"value",@"value",
                @"important",@"important",
                nil];
  });
  
  return mappings;
}

@dynamic name, value, important;

@end

@implementation PDCSSPropertyInfo

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"name",@"name",
                @"longhands",@"longhands",
                nil];
  });
  
  return mappings;
}

@dynamic name, longhands;

@end

@implementation PDCSSComputedStyleProperty

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"name",@"name",
                @"value",@"value",
                nil];
  });
  
  return mappings;
}

@dynamic name, value;

@end

@implementation PDCSSProperty

+ (instancetype)propertyWithName:(NSString *)name value:(NSString *)value
{
  PDCSSProperty *property = [[PDCSSProperty alloc] init];
  property.name = name;
  property.value = value;
  return property;
}

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"name",@"name",
                @"value",@"value",
                @"important",@"important",
                @"implicit",@"implicit",
                @"text",@"text",
                @"parsedOk",@"parsedOk",
                @"disabled",@"disabled",
                @"range",@"range",
                nil];
  });
  
  return mappings;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.range = [[PDCSSSourceRange alloc] init];
  }
  return self;
}

@dynamic name, value, important, implicit, text, parsedOk, disabled, range;

@end

@implementation PDCSSSelectorProfileEntry

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"selector",@"selector",
                @"url",@"url",
                @"lineNumber",@"lineNumber",
                @"time",@"time",
                @"hitCount",@"hitCount",
                @"matchCount",@"matchCount",
                nil];
  });
  
  return mappings;
}

@dynamic selector, url, lineNumber, time, hitCount, matchCount;

@end

@implementation PDCSSSelectorProfile

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"totalTime",@"totalTime",
                @"data",@"data",
                nil];
  });
  
  return mappings;
}

@dynamic totalTime, data;

@end

@implementation PDCSSRegion

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"regionOverset",@"regionOverset",
                @"nodeId",@"nodeId",
                nil];
  });
  
  return mappings;
}

@dynamic regionOverset, nodeId;

@end

@implementation PDCSSNamedFlow

+ (NSDictionary *)keysToEncode;
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"documentNodeId",@"documentNodeId",
                @"name",@"name",
                @"overset",@"overset",
                @"content",@"content",
                @"regions",@"regions",
                nil];
  });
  
  return mappings;
}

@dynamic documentNodeId, name, overset, content, regions;

@end

@implementation PDCSSStyleDeclarationEdit

+ (NSDictionary *)keysToEncode
{
  static NSDictionary *mappings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mappings = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"styleSheetId",@"styleSheetId",
                @"range",@"range",
                @"text",@"text",
                nil];
  });
  
  return mappings;
}

@dynamic styleSheetId, range, text;

@end
