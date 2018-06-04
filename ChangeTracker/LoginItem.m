//
//  LoginItem.m
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

#import "LoginItem.h"

@implementation LoginItem

+(BOOL) registerLoginItem:(NSString *)loginItemName error:(NSError **)errorp
{
    NSLog(@"Lazy-load implementation: registerLoginItem");
    return true;
}

@end
