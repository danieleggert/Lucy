//
//  CommentReplacer.m
//  SourceCodeCommentParser
//
//  Created by Daniel Eggert on 18/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import "CommentReplacer.h"

//
// We need to insert C preprocessor comments into the source code to enable debugging.
// Source code lines look like this:
//     # 348 "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation.framework/Headers/NSURLConnection.h" 3

// i.e. (1) "#", (2) line number, (3) file path
//


@interface CommentReplacer ()

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic) NSUInteger lineNumber;

@end



@implementation CommentReplacer

+ (instancetype)replacerForFileAtURL:(NSURL *)fileURL;
{
    CommentReplacer *replacer = [[self alloc] init];
    replacer.fileURL = fileURL;
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
    
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableArray *commentLines = [NSMutableArray array];
    self.lineNumber = 0;
    
    [lines addObject:[NSString stringWithFormat:@"// Layout constraints output for %@ generated at %@",
                      self.fileName, [NSDate date]]];
    [lines addObject:[self preprocessorCommentForCurrentLine]];
    BOOL needsToOutputLineNumber = YES;
    NSUInteger startLine = NSNotFound;
    
    while (! [scanner isAtEnd]) {
        @autoreleasepool {
            NSString *line = nil;
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            self.lineNumber++;
            if (needsToOutputLineNumber) {
                needsToOutputLineNumber = NO;
                [lines addObject:[self preprocessorCommentForCurrentLine]];
            }
            
            if (startLine == NSNotFound) {
                NSRange range = [line rangeOfString:self.startMarker options:0];
                if (range.location != NSNotFound) {
                    startLine = self.lineNumber;
                    if (0 < range.location) {
                        [lines addObject:[line substringToIndex:range.location]];
                    }
                    [commentLines addObject:[line substringFromIndex:NSMaxRange(range)]];
                }
            } else if (startLine != self.lineNumber) {
                NSRange range = [line rangeOfString:self.endMarker options:0];
                if (range.location != NSNotFound) {
                    if (0 < range.location) {
                        [commentLines addObject:[line substringToIndex:range.location]];
                    }
                    [lines addObjectsFromArray:[self processCommentLines:commentLines]];
                    [commentLines removeAllObjects];
                    needsToOutputLineNumber = YES;
                    startLine = NSNotFound;
                }
            }
        }
    }
    
    return [lines componentsJoinedByString:@"\n"];
}
                 
- (NSString *)startMarker;
{
    return @"/*[LayoutConstraints]";
}

- (NSString *)endMarker;
{
    return @"*/";
}

- (NSString *)preprocessorCommentForCurrentLine;
{
    return [NSString stringWithFormat:@"# %lu \"%@\"",
            (unsigned long) self.lineNumber,
            [self.fileURL path]];
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
    NSArray *output = [self.commentParser processedLinesFromLines:commentLines];
    return (output == nil) ? @[] : output;
}

@end
