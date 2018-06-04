//
//  LoginItem.h
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginItem : NSObject

+(BOOL) registerLoginItem:(NSString *)loginItemName error:(NSError **)errorp;

@end
