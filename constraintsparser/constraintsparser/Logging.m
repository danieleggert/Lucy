//
//  Logging.m
//  constraintsparser
//
//  Created by Daniel Eggert on 19/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "Logging.h"

void PrintToStdErr(NSString *format, ...)
{
    @autoreleasepool {
        va_list args;
        va_start(args, format);
        NSString *output = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        NSFileHandle *handle = [NSFileHandle fileHandleWithStandardError];
        NSData *data = [output dataUsingEncoding:NSUTF8StringEncoding];
        [handle writeData:data];
        [handle writeData:[NSData dataWithBytes:(char const []){'\n'} length:1]];
    }
}
