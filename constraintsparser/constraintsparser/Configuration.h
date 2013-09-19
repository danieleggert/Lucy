//
//  Configuration.h
//  constraintsparser
//
//  Created by Daniel Eggert on 19/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Configuration : NSObject

+ (BOOL)isDebugBuild;

+ (BOOL)shouldAddDebugInfo;

@end
