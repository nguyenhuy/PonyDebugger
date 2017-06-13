//
//  PDCSSDomain.h
//  PonyDebuggerDerivedSources
//
//  Generated on 8/23/12
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import <PonyDebugger/PDObject.h>
#import <PonyDebugger/PDDebugger.h>
#import <PonyDebugger/PDDynamicDebuggerDomain.h>

@class PDCSSRule;
@class PDCSSStyleId;
@class PDCSSStyleSheetBody;
@class PDCSSStyle;
@class PDCSSSelectorProfile;
@class PDCSSNamedFlow;
@class PDCSSRuleMatch;
@class PDCSSComputedStyleProperty;
@class PDCSSStyleDeclarationEdit;

@protocol PDCSSCommandDelegate;

// This domain exposes CSS read/write operations. All CSS objects, like stylesheets, rules, and styles, have an associated <code>id</code> used in subsequent operations on the related object. Each object type has a specific <code>id</code> structure, and those are not interchangeable between objects of different kinds. CSS objects can be loaded using the <code>get*ForNode()</code> calls (which accept a DOM node id). Alternatively, a client can discover all the existing stylesheets with the <code>getAllStyleSheets()</code> method and subsequently load the required stylesheet contents using the <code>getStyleSheet[Text]()</code> methods.
@interface PDCSSDomain : PDDynamicDebuggerDomain 

@property (nonatomic, weak) id <PDCSSCommandDelegate, PDCommandDelegate> delegate;

// Events

// Fires whenever a MediaQuery result changes (for example, after a browser window has been resized.) The current implementation considers only viewport-dependent media features.
- (void)mediaQueryResultChanged;

// Fired whenever a stylesheet is changed as a result of the client operation.
- (void)styleSheetChangedWithStyleSheetId:(NSString *)styleSheetId;

// Fires when a Named Flow is created.
// Param documentNodeId: The document node id.
// Param namedFlow: Identifier of the new Named Flow.
- (void)namedFlowCreatedWithDocumentNodeId:(NSNumber *)documentNodeId namedFlow:(NSString *)namedFlow;

// Fires when a Named Flow is removed: has no associated content nodes and regions.
// Param documentNodeId: The document node id.
// Param namedFlow: Identifier of the removed Named Flow.
- (void)namedFlowRemovedWithDocumentNodeId:(NSNumber *)documentNodeId namedFlow:(NSString *)namedFlow;

@end

@protocol PDCSSCommandDelegate <PDCommandDelegate>
@optional

// Enables the CSS agent for the given page. Clients should not assume that the CSS agent has been enabled until the result of this command is received.
- (void)domain:(PDCSSDomain *)domain enableWithCallback:(void (^)(id error))callback;

// Disables the CSS agent for the given page.
- (void)domain:(PDCSSDomain *)domain disableWithCallback:(void (^)(id error))callback;

// Returns requested styles for a DOM node identified by <code>nodeId</code>.
// Param includePseudo: Whether to include pseudo styles (default: true).
// Param includeInherited: Whether to include inherited styles (default: true).
// Callback Param matchedCSSRules: CSS rules matching this node, from all applicable stylesheets.
// Callback Param pseudoElements: Pseudo style rules for this node.
// Callback Param inherited: A chain of inherited styles (from the immediate node parent up to the DOM tree root).
- (void)domain:(PDCSSDomain *)domain getMatchedStylesForNodeWithNodeId:(NSNumber *)nodeId includePseudo:(NSNumber *)includePseudo includeInherited:(NSNumber *)includeInherited callback:(void (^)(NSArray<PDCSSRuleMatch *> *matchedCSSRules, NSArray *pseudoElements, NSArray *inherited, id error))callback;

// Applies specified style edits one after another in the given order.
// Callback Param styles: The resulting styles after modification.
- (void)domain:(PDCSSDomain *)domain setStyleTextsWithEdits:(NSArray<NSDictionary *> *)edits callback:(void (^)(NSArray<PDCSSStyle *> *styles, id error))callback;

@end

@interface PDDebugger (PDCSSDomain)

@property (nonatomic, readonly, strong) PDCSSDomain *CSSDomain;

@end
