//
//  ConstrainsParser.m
//  constraintsparser
//
//  Created by Daniel Eggert on 19/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "ConstrainsParser.h"

#import "Logging.h"
#import "CommentReplacer.h"



@interface ConstrainsParser ()

@property (nonatomic, strong) NSURL *inputFileURL;
@property (nonatomic, strong) NSURL *outputFileURL;

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
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSUInteger const argc = [arguments count];
    NSUInteger i = 1; // Skip command name
    for ( ; i < argc; ++i) {
        NSString *arg = arguments[i];
        if ([arg hasPrefix:@"-"]) {
            if ([arg isEqualToString:@"-o"]) {
                ++i;
                if (argc <= i) {
                    PrintToStdErr(@"Missing argument for %@", arg);
                    exit(-1);
                } else {
                    NSString *path = arguments[i];
                    self.outputFileURL = [NSURL fileURLWithPath:path];
                }
            } else {
                PrintToStdErr(@"Unknown argument %@", arg);
                exit(-1);
            }
        } else {
            if (self.inputFileURL != nil) {
                PrintToStdErr(@"Unexpected argument %@", arg);
                exit(-1);
            } else {
                self.inputFileURL = [NSURL fileURLWithPath:arg];
            }
        }
    }
    if (self.inputFileURL == nil) {
        PrintToStdErr(@"No input file specified.");
        exit(-1);
    }
    if (self.outputFileURL == nil) {
        PrintToStdErr(@"No output file specified.");
        exit(-1);
    }
    
    NSURL *outputDirectory = [self.outputFileURL URLByDeletingLastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (! [fm fileExistsAtPath:[outputDirectory path]]) {
        NSError *error = nil;
        if (! [fm createDirectoryAtURL:outputDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            PrintToStdErr(@"Unable to create output directory \"%@\": %@", [outputDirectory path], error);
            exit(-1);
        }
    }
}

- (void)run;
{
    CommentReplacer *replacer = [CommentReplacer replacerForFileAtURL:self.inputFileURL outputFileURL:self.outputFileURL];
    NSData *outputData = [replacer processedFileData];
    if (outputData == nil) {
        PrintToStdErr(@"Unable to process file.");
        exit(-1);
    }
    NSError *error = nil;
    if (! [outputData writeToURL:self.outputFileURL options:0 error:&error]) {
        PrintToStdErr(@"Unable to write output file: %@", error);
        exit(-1);
    }
}

@end
