//
//  PDCSSDomain.m
//  PonyDebuggerDerivedSources
//
//  Generated on 8/23/12
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import <PonyDebugger/PDObject.h>
#import <PonyDebugger/PDCSSDomain.h>
#import <PonyDebugger/PDObject.h>
#import <PonyDebugger/PDCSSTypes.h>


@interface PDCSSDomain ()
//Commands

@end

@implementation PDCSSDomain

@dynamic delegate;

+ (NSString *)domainName;
{
    return @"CSS";
}

// Events

// Fires whenever a MediaQuery result changes (for example, after a browser window has been resized.) The current implementation considers only viewport-dependent media features.
- (void)mediaQueryResultChanged;
{
    [self.debuggingServer sendEventWithName:@"CSS.mediaQueryResultChanged" parameters:nil];
}

// Fired whenever a stylesheet is changed as a result of the client operation.
- (void)styleSheetChangedWithStyleSheetId:(NSString *)styleSheetId;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];

    if (styleSheetId != nil) {
        [params setObject:[styleSheetId PD_JSONObject] forKey:@"styleSheetId"];
    }
    
    [self.debuggingServer sendEventWithName:@"CSS.styleSheetChanged" parameters:params];
}

// Fires when a Named Flow is created.
- (void)namedFlowCreatedWithDocumentNodeId:(NSNumber *)documentNodeId namedFlow:(NSString *)namedFlow;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];

    if (documentNodeId != nil) {
        [params setObject:[documentNodeId PD_JSONObject] forKey:@"documentNodeId"];
    }
    if (namedFlow != nil) {
        [params setObject:[namedFlow PD_JSONObject] forKey:@"namedFlow"];
    }
    
    [self.debuggingServer sendEventWithName:@"CSS.namedFlowCreated" parameters:params];
}

// Fires when a Named Flow is removed: has no associated content nodes and regions.
- (void)namedFlowRemovedWithDocumentNodeId:(NSNumber *)documentNodeId namedFlow:(NSString *)namedFlow;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];

    if (documentNodeId != nil) {
        [params setObject:[documentNodeId PD_JSONObject] forKey:@"documentNodeId"];
    }
    if (namedFlow != nil) {
        [params setObject:[namedFlow PD_JSONObject] forKey:@"namedFlow"];
    }
    
    [self.debuggingServer sendEventWithName:@"CSS.namedFlowRemoved" parameters:params];
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
    } else if ([methodName isEqualToString:@"getMatchedStylesForNode"] && [self.delegate respondsToSelector:@selector(domain:getMatchedStylesForNodeWithNodeId:includePseudo:includeInherited:callback:)]) {
        [self.delegate domain:self getMatchedStylesForNodeWithNodeId:[params objectForKey:@"nodeId"] includePseudo:[params objectForKey:@"includePseudo"] includeInherited:[params objectForKey:@"includeInherited"] callback:^(NSArray<PDCSSRuleMatch *> *matchedCSSRules, NSArray *pseudoElements, NSArray *inherited, id error) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];

            if (matchedCSSRules != nil) {
                [params setObject:matchedCSSRules forKey:@"matchedCSSRules"];
            }
            if (pseudoElements != nil) {
                [params setObject:pseudoElements forKey:@"pseudoElements"];
            }
            if (inherited != nil) {
                [params setObject:inherited forKey:@"inherited"];
            }

            responseCallback(params, error);
        }];
    } else if ([methodName isEqualToString:@"setStyleTexts"] && [self.delegate respondsToSelector:@selector(domain:setStyleTextsWithEdits:callback:)]) {
        [self.delegate domain:self setStyleTextsWithEdits:[params objectForKey:@"edits"] callback:^(NSArray<PDCSSStyle *> *styles, id error) {
          NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
          
          if (styles != nil) {
            [params setObject:styles forKey:@"styles"];
          }
          
          responseCallback(params, error);
        }];
    } else {
        [super handleMethodWithName:methodName parameters:params responseCallback:responseCallback];
    }
}

@end


@implementation PDDebugger (PDCSSDomain)

- (PDCSSDomain *)CSSDomain;
{
    return [self domainForName:@"CSS"];
}

@end
