//
//  LoginItem.m
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

// Some code here derived from Apple sample iDecide code
//     File: NSXPCConnection+LoginItem.m
// Abstract: Category adding methods to NSXPCConnection for connecting to services hosted by login items
//  Version: 1.1
//
// Copyright (C) 2012 Apple Inc. All Rights Reserved.
//
// This code is distributed with modifications, so it is not necessary
// to reproduce the license notice here

#import "LoginItem.h"

#import <ServiceManagement/ServiceManagement.h>

@implementation LoginItem

+(BOOL) registerLoginItem:(NSString *)loginItemName error:(NSError **)errorp
{
    NSLog(@"Lazy-load implementation: registerLoginItem");
    NSURL *mainBundleURL = [[NSBundle mainBundle] bundleURL];
    NSURL *loginItemDirURL = [mainBundleURL URLByAppendingPathComponent:@"Contents/XPCServices" isDirectory:YES];
    NSURL *loginItemURL = [loginItemDirURL URLByAppendingPathComponent:loginItemName];
    
    NSBundle *loginItemBundle = [NSBundle bundleWithURL:loginItemURL];
    if (loginItemBundle == nil) {
        if (errorp != NULL) {
            *errorp = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
                        NSLocalizedFailureReasonErrorKey: @"failed to load bundle",                              NSURLErrorKey: loginItemURL
                      }];
        }
        return false;
    }
    
    // Lookup the bundle identifier for the login item.
    // LaunchServices implicitly registers a mach service for the login
    // item whose name is the name as the login item's bundle identifier.
    NSString *loginItemBundleId = [loginItemBundle bundleIdentifier];
    if (loginItemBundleId == nil) {
        if (errorp != NULL) {
            *errorp = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
                                            NSLocalizedFailureReasonErrorKey: @"bundle has no identifier",
                                            NSURLErrorKey: loginItemURL
                      }];
        }
        return false;
    }
    
    // Enable the login item.
    // This will start it running if it wasn't already running.
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)loginItemBundleId, true)) {
        if (errorp != NULL) {
            *errorp = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
                               NSLocalizedFailureReasonErrorKey: @"SMLoginItemSetEnabled() failed"
                       }];
        }
        return false;
    }
    
    return true;
}

@end
