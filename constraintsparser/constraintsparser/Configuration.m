//
//  Configuration.m
//  constraintsparser
//
//  Created by Daniel Eggert on 19/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "Configuration.h"



@implementation Configuration

+ (BOOL)isDebugBuild;
{
    return [[[NSProcessInfo processInfo] environment][@"CONFIGURATION"] hasPrefix:@"Debug"];
}

+ (BOOL)shouldAddDebugInfo;
{
    return [[[NSProcessInfo processInfo] environment][@"COPY_PHASE_STRIP"] hasPrefix:@"NO"];
}

@end
