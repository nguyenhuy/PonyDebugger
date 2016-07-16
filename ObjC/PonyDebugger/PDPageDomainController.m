//
//  PDPageDomainController.m
//  PonyDebugger
//
//  Created by Wen-Hao Lue on 8/6/12.
//
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import "PDPageDomainController.h"
#import "PDRuntimeDomainController.h"
#import "PDPageDomain.h"
#import "PDPageTypes.h"
#import <UIKit/UIKit.h>

@interface PDPageDomainController () <PDPageCommandDelegate>
@end


@implementation PDPageDomainController

@dynamic domain;

#pragma mark - Statics

+ (PDPageDomainController *)defaultInstance;
{
    static PDPageDomainController *defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[PDPageDomainController alloc] init];
    });
    
    return defaultInstance;
}

+ (Class)domainClass;
{
    return [PDPageDomain class];
}

- (NSArray*)resourceTreesForPath:(NSString*)path{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSFileManager *fm;
    fm = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator<NSString *> *subdirs = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for(NSString *subdir in subdirs){
        NSString *subpath = [path stringByAppendingPathComponent:subdir];
        BOOL isSubDirDir;
        BOOL exists = [fm fileExistsAtPath:subpath isDirectory:&isSubDirDir];
        if(exists){
            if(!isSubDirDir){
                PDPageFrame *frame = [[PDPageFrame alloc] init];
                
                frame.identifier = [NSString stringWithFormat:@"%d", 1];
                frame.name = path;
                frame.securityOrigin = [[NSBundle mainBundle] bundleIdentifier];
                frame.url = subpath;
                frame.loaderId = @"0";
                frame.mimeType = @"";
                
                PDPageFrameResourceTree *resourceTree = [[PDPageFrameResourceTree alloc] init];
                resourceTree.frame = frame;
                resourceTree.resources = @[];
                resourceTree.childFrames = @[];
                [arr addObject:resourceTree];
            }
        }
    }
    
    return arr;
}

#pragma mark - PDPageCommandDelegate

- (void)domain:(PDPageDomain *)domain getResourceTreeWithCallback:(void (^)(PDPageFrameResourceTree *, id))callback;
{
    PDPageFrame *frame = [[PDPageFrame alloc] init];
    
    frame.identifier = @"0";
    frame.name = @"Root";
    frame.securityOrigin = [[NSBundle mainBundle] bundleIdentifier];
    frame.url = [[NSBundle mainBundle] bundlePath];
    frame.loaderId = @"0";
    frame.mimeType = @"";
    
    PDPageFrameResourceTree *resourceTree = [[PDPageFrameResourceTree alloc] init];
    resourceTree.frame = frame;
    resourceTree.resources = @[];
    resourceTree.childFrames = [self resourceTreesForPath:NSHomeDirectory()];

    resourceTree.resources = @[@{
        @"url": [NSBundle mainBundle].bundleURL.absoluteString,
        @"type": @"Document",
        @"mimeType": @"",
        
    }];
    
    callback(resourceTree, nil);
}

- (void)domain:(PDPageDomain *)domain reloadWithIgnoreCache:(NSNumber *)ignoreCache scriptToEvaluateOnLoad:(NSString *)scriptToEvaluateOnLoad callback:(void (^)(id))callback;
{
    callback(nil);
}


- (void)domain:(PDPageDomain *)domain getResourceContentWithFrameId:(NSString *)frameId url:(NSString *)url callback:(void (^)(NSString *content, NSNumber *base64Encoded, id error))callback{
    
    if([url isEqualToString:[[NSBundle mainBundle] bundlePath]]){
        //return info.plust
        NSString *infoPlistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        id plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:infoPlistPath] options:0 format:nil error:nil];
        if(plist){
            NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
            if(xmlData){
                callback([[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding], @(0), nil);
            }
            else{
                callback(@"", @(0), nil);
            }
        }
        else{
            callback(@"", @(0), nil);
        }
        return;
    }
    
    NSFileManager *fm;
    fm = [NSFileManager defaultManager];
    BOOL isSubDirDir;
    BOOL exists = [fm fileExistsAtPath:url isDirectory:&isSubDirDir];
    if(exists){
        if(!isSubDirDir){
            
            id plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:url] options:0 format:nil error:nil];
            if(plist){
                NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
                if(xmlData){
                    callback([[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding], @(0), nil);
                }
            }
            else{
                NSString *content = [NSString stringWithContentsOfFile:url encoding:NSUTF8StringEncoding error:nil];
                if(content){
                    callback(content, @(0), nil);
                    return;
                }
                else{
                    content = [NSString stringWithContentsOfFile:url encoding:NSASCIIStringEncoding error:nil];
                    if(content){
                        callback(content, @(0), nil);
                        return;
                    }
                    else{
                        NSData *data = [NSData dataWithContentsOfFile:url];
                        if(data){
                            callback([data description], @(0), nil);
                            return;
                        }
                    }
                }
            }
        }
    }
    if(isSubDirDir){
        callback([NSString stringWithFormat:@"<html>This is a directory, %@</html>", url], @(NO), nil);
    }
    else{
        callback([NSString stringWithFormat:@"<html>Content here. %@</html>", url], @(NO), nil);
    }
}

- (void)screencastFrame{
    dispatch_async(dispatch_get_main_queue(),^{
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [keyWindow bounds];
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext:context];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *data = UIImageJPEGRepresentation(img, 0.5);
        NSString *dataBase64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        CGSize size = [UIScreen mainScreen].bounds.size;
        [self.domain.debuggingServer sendEventWithName:@"Page.screencastFrame" parameters:@{@"data":dataBase64, @"metadata":@{@"offsetTop":@0,@"pageScaleFactor":@1,@"deviceWidth":@(size.width), @"deviceHeight":@(size.height),@"scrollOffsetX":@0,@"scrollOffsetY":@0}, @"sessionId":@1}];
    });
}

static NSTimer *screencastTimer;

- (void)domain:(PDPageDomain *)domain startScreencast:(void (^)(id error))callback{
    if(screencastTimer == nil){
        screencastTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(screencastFrame) userInfo:nil repeats:YES];
    }
    
    callback(nil);
}

- (void)domain:(PDPageDomain *)domain screencastFrameAck:(void (^)(id error))callback{
    
    callback(nil);
}

- (void)domain:(PDPageDomain *)domain stopScreencast:(void (^)(id error))callback{
    [screencastTimer invalidate];
    screencastTimer = nil;
    callback(nil);
}


- (void)domain:(PDPageDomain *)domain canScreencastWithCallback:(void (^)(NSNumber *, id))callback;
{
    callback(@YES, nil);
}


@end
