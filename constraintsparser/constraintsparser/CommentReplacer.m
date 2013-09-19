//
//  CommentReplacer.m
//  SourceCodeCommentParser
//
//  Created by Daniel Eggert on 18/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "CommentReplacer.h"

#import "Logging.h"
#import "AutoLayoutCommentProcessor.h"



//
// We need to insert C preprocessor comments into the source code to enable debugging.
// Source code lines look like this:
//     # 348 "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSURLConnection.h" 3

// i.e. (1) "#", (2) line number, (3) file path
//


@interface CommentReplacer () <LineParserDelegate>

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSURL *outputFileURL;
@property (nonatomic) NSUInteger lineNumber;
@property (nonatomic) NSUInteger startLine;
@property (nonatomic, strong) NSMutableArray *lines;

@end



@implementation CommentReplacer

+ (instancetype)replacerForFileAtURL:(NSURL *)fileURL outputFileURL:(NSURL *)outputFileURL;
{
    CommentReplacer *replacer = [[self alloc] init];
    replacer.lineControlUsesFullPath = YES;
    replacer.fileURL = fileURL;
    replacer.outputFileURL = outputFileURL;
    replacer.commentParser = [[AutoLayoutCommentProcessor alloc] init];
    return replacer;
}

@synthesize processedFileData = _processedFileData;
- (NSData *)processedFileData;
{
    if (_processedFileData == nil) {
        _processedFileData = [self generateFileData];
    }
    return _processedFileData;
}

- (NSString *)fileName;
{
    return [self.fileURL lastPathComponent];
}

- (NSData *)generateFileData;
{
    return [[self generateFileString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)generateFileString;
{
    NSString *sourceCode = self.sourceCode;
    NSScanner *scanner = [NSScanner scannerWithString:sourceCode];
    scanner.charactersToBeSkipped = [NSCharacterSet illegalCharacterSet];
    
    self.lines = [NSMutableArray array];
    NSMutableArray *commentLines = [NSMutableArray array];
    self.lineNumber = 0;
    
    BOOL needsToOutputLineNumber = YES;
    self.startLine = 0;
    
    NSCharacterSet *newlineSet = [NSCharacterSet newlineCharacterSet];
    
    while (! [scanner isAtEnd]) {
        @autoreleasepool {
            NSString *line = @"";
            [scanner scanUpToCharactersFromSet:newlineSet intoString:&line];
            self.lineNumber++;
            
            if (needsToOutputLineNumber) {
                needsToOutputLineNumber = NO;
                [self.lines addObject:[self preprocessorCommentForCurrentInputLine]];
            }
            
            if (self.startLine == 0) {
                NSRange range = [line rangeOfString:self.startMarker options:0];
                if (range.length != 0) {
                    self.startLine = self.lineNumber;
                    if (0 < range.location) {
                        [self.lines addObject:[line substringToIndex:range.location]];
                    }
                    if (NSMaxRange(range) < [line length]) {
                        [commentLines addObject:[line substringFromIndex:NSMaxRange(range)]];
                    } else {
                        [commentLines addObject:@""];
                    }
                } else {
                    [self.lines addObject:line];
                }
            } else if (self.startLine != self.lineNumber) {
                NSRange range = [line rangeOfString:self.endMarker options:0];
                if (range.length != 0) {
                    if (0 < range.location) {
                        [commentLines addObject:[line substringToIndex:range.location]];
                    }
                    [self addPreprocessorCommentForCurrentOutputLine];
                    [self.lines addObjectsFromArray:[self processCommentLines:commentLines]];
                    [commentLines removeAllObjects];
                    needsToOutputLineNumber = YES;
                    self.startLine = 0;
                } else {
                    [commentLines addObject:line];
                }
            }
            // Do this little dance to make sure we add a line break at the end if the input file had one.
            if ([scanner isAtEnd]) {
                break;
            }
            [scanner scanString:@"\n" intoString:NULL];
            if ([scanner isAtEnd]) {
                [self.lines addObject:@""];
                break;
            }
        }
    }
    
    return [self.lines componentsJoinedByString:@"\n"];
}
                 
- (NSString *)startMarker;
{
    return @"/*[LayoutConstraints]";
}

- (NSString *)endMarker;
{
    return @"*/";
}

- (NSString *)preprocessorCommentForCurrentInputLine;
{
    NSString *fileName = (self.lineControlUsesFullPath ?
                          [self.fileURL path] :
                          [self.fileURL lastPathComponent]);
    return [NSString stringWithFormat:@"#line %lu \"%@\"", (unsigned long) self.lineNumber, fileName];
}

- (void)addPreprocessorCommentForCurrentOutputLine;
{
    NSString *fileName = (self.lineControlUsesFullPath ?
                          [self.outputFileURL path] :
                          [self.outputFileURL lastPathComponent]);
    NSUInteger lineNumber = [self.lines count] + 2ULL;
    NSString *line = [NSString stringWithFormat:@"#line %lu \"%@\"", (unsigned long) lineNumber, fileName];
    [self.lines addObject:line];
}

- (NSString *)sourceCode;
{
    NSError *error = nil;
    NSString *sourceCode = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:&error];
    NSAssert(sourceCode != nil, @"Unable to read \"%@\": %@", [self.fileURL path], error);
    return sourceCode;
}

- (NSArray *)processCommentLines:(NSArray *)commentLines;
{
    NSArray *output = [self.commentParser processedLinesFromLines:commentLines errorHandler:self];
    return (output == nil) ? @[] : output;
}

- (void)logErrorString:(NSString *)errorString forLineAtIndex:(NSUInteger)relativeLineIndex;
{
    PrintToStdErr(@"%@:%lu: error: %@", [self.fileURL path], self.startLine + relativeLineIndex, errorString);
}

- (NSString *)fileAndLineDescriptinForLineAtIndex:(NSUInteger)relativeLineIndex;
{
    return [NSString stringWithFormat:@"%@:%lu", [self.fileURL path], self.startLine + relativeLineIndex];
}

@end
