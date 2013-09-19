//
//  ConstrainsParser.m
//  constraintsparser
//
//  Created by Daniel Eggert on 19/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "ConstrainsParser.h"


@interface ConstrainsParser ()
@end



@implementation ConstrainsParser

+ (void)run;
{
    ConstrainsParser *parser = [[ConstrainsParser alloc] init];
    [parser run];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self parseCommandLineArguments];
    }
    return self;
}

- (void)parseCommandLineArguments;
{
}

- (void)run;
{
}

@end
