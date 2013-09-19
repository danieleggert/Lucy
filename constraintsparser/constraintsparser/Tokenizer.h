//
// Created by chris on 9/18/13.
//

#import <Foundation/Foundation.h>

static NSString* const errorDomain = @"io.objc";
#define fail(x) [NSError errorWithDomain:errorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey : x}]

@interface Tokenizer : NSObject

- (NSArray*)tokenize:(NSString*)string error:(NSError**)error;

@end
