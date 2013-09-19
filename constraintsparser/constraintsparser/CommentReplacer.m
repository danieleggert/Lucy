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
    replacer.lineControlUsesFullPath = YES;
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
    
    BOOL needsToOutputLineNumber = YES;
    NSUInteger startLine = 0;
    
    NSCharacterSet *newlineSet = [NSCharacterSet newlineCharacterSet];
    
    while (! [scanner isAtEnd]) {
        @autoreleasepool {
            NSString *line = nil;
            [scanner scanUpToCharactersFromSet:newlineSet intoString:&line];
            self.lineNumber++;
            
            if (needsToOutputLineNumber) {
                needsToOutputLineNumber = NO;
                [lines addObject:[self preprocessorCommentForCurrentLine]];
            }
            
            if (startLine == 0) {
                NSRange range = [line rangeOfString:self.startMarker options:0];
                if (range.length != 0) {
                    startLine = self.lineNumber;
                    if (0 < range.location) {
                        [lines addObject:[line substringToIndex:range.location]];
                    }
                    if (NSMaxRange(range) < [line length]) {
                        [commentLines addObject:[line substringFromIndex:NSMaxRange(range)]];
                    }
                } else {
                    [lines addObject:line];
                }
            } else if (startLine != self.lineNumber) {
                NSRange range = [line rangeOfString:self.endMarker options:0];
                if (range.length != 0) {
                    if (0 < range.location) {
                        [commentLines addObject:[line substringToIndex:range.location]];
                    }
                    [lines addObjectsFromArray:[self processCommentLines:commentLines]];
                    [commentLines removeAllObjects];
                    needsToOutputLineNumber = YES;
                    startLine = 0;
                } else {
                    [commentLines addObject:line];
                }
            }
            // Do this little dance to make sure we add a line break at the end if the input file had one.
            if ([scanner isAtEnd]) {
                break;
            }
            [scanner scanCharactersFromSet:newlineSet intoString:NULL];
            if ([scanner isAtEnd]) {
                [lines addObject:@""];
                break;
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
    NSString *fileName = (self.lineControlUsesFullPath ?
                          [self.fileURL path] :
                          [self.fileURL lastPathComponent]);
    return [NSString stringWithFormat:@"#line %lu \"%@\"", (unsigned long) self.lineNumber, fileName];
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
