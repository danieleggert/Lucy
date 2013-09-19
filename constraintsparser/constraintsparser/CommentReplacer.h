//
//  CommentReplacer.h
//  SourceCodeCommentParser
//
//  Created by Daniel Eggert on 18/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommentParser;
@protocol LineErrorHandler;



@interface CommentReplacer : NSObject

+ (instancetype)replacerForFileAtURL:(NSURL *)fileURL outputFileURL:(NSURL *)outputFileURL;

@property (nonatomic, strong) id<CommentParser> commentParser;
@property (nonatomic) BOOL lineControlUsesFullPath;
@property (readonly, nonatomic, copy) NSData *processedFileData;

@end



@protocol CommentParser <NSObject>

- (NSArray *)processedLinesFromLines:(NSArray *)inputLines errorHandler:(id<LineErrorHandler>)errorHandler;

@end



@protocol LineErrorHandler <NSObject>

- (void)logErrorString:(NSString *)errorString forLineAtIndex:(NSUInteger)relativeLineIndex;

@end
