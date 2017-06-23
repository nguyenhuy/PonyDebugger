//
//  PDDebugger.h
//  PonyDebugger
//
//  Created by Mike Lewis on 11/5/11.
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import <Foundation/Foundation.h>

#pragma mark - Definitions

@class SRWebSocket;
@class PDDomainController;

@interface PDDebugger : NSObject

+ (PDDebugger *)defaultInstance;

- (id)domainForName:(NSString *)name;
- (void)sendEventWithName:(NSString *)string parameters:(id)params;

#pragma mark Connect/Disconnect
- (void)autoConnect;
- (void)autoConnectToBonjourServiceNamed:(NSString*)serviceName;
- (void)connectToURL:(NSURL *)url;
- (BOOL)isConnected;
- (void)disconnect;

#pragma mark Custom Controller Support
- (void)addController:(PDDomainController *)controller;

@end
