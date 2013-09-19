//
//  Parser.m
//  TwoDimensionalParser
//
//  Created by Chris Eidhof on 9/18/13.
//  Copyright (c) 2013 Chris Eidhof. All rights reserved.
//

#import "Parser.h"
#import "Tokenizer.h"
#import "LayoutConstraint.h"

@interface Parser ()

@property (nonatomic, strong) NSArray* tokens;
@property (nonatomic) NSUInteger cursor;
@property (nonatomic, strong) NSDictionary* attributes;
@end

@implementation Parser

- (id)init
{
    self = [super init];
    if (self) {
        self.attributes = @{
                @"left": @(NSLayoutAttributeLeft),
                @"right": @(NSLayoutAttributeRight),
                @"top": @(NSLayoutAttributeTop),
                @"bottom": @(NSLayoutAttributeBottom),
                @"leading": @(NSLayoutAttributeLeading),
                @"trailing": @(NSLayoutAttributeTrailing),
                @"width": @(NSLayoutAttributeWidth),
                @"height": @(NSLayoutAttributeHeight),
                @"centerX": @(NSLayoutAttributeCenterX),
                @"centerY": @(NSLayoutAttributeCenterY),
                @"baseline": @(NSLayoutAttributeBaseline),
        };
    }

    return self;
}

#define fail(x) [NSError errorWithDomain:errorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey : x}]

- (LayoutConstraint*)parse:(NSString*)string error:(NSError**)error
{
    NSError* theError;
    Tokenizer* tokenizer = [Tokenizer new];
    self.tokens = [tokenizer tokenize:string];
    self.cursor = 0;
    LayoutConstraint* constraint = [self parseEquation:&theError];
    if (theError) {
        if (error) {
            *error = theError;
        }
        return nil;
    }
    return constraint;
}

#define RETURN_NIL_IF_ERROR if (error && *error) return nil;

- (LayoutConstraint*)parseEquation:(NSError**)error
{
    NSArray* firstItem = [self objcExpression:error];
    RETURN_NIL_IF_ERROR
    NSLayoutAttribute firstAttribute = [self attributeWithError:error];
    RETURN_NIL_IF_ERROR
    NSLayoutRelation relation = [self relationWithError:error ];
    RETURN_NIL_IF_ERROR

    NSArray* secondItem = nil;
    NSLayoutAttribute secondAttribute = NSLayoutAttributeNotAnAttribute;
    CGFloat constant = 0;
    CGFloat multiplier = 1;
    NSString* targetIdentifier = nil;
    if ([self.peek isKindOfClass:[NSNumber class]]) {
        constant = [self parseFloatWithError:error ];
        RETURN_NIL_IF_ERROR
        if (![self.peek isEqual:@"+"]) goto end;
        [self operator:@"+" error:error];
        RETURN_NIL_IF_ERROR
    }

    secondItem = [self objcExpression:error];
    RETURN_NIL_IF_ERROR

    secondAttribute = [self attributeWithError:&error ];
    RETURN_NIL_IF_ERROR
    if ([self.peek isEqual:@"*"]) {
        [self operator:@"*" error:error ];
        RETURN_NIL_IF_ERROR
        multiplier = [self parseFloatWithError:NULL ];
        RETURN_NIL_IF_ERROR
    }
end:    
    if ([self.peek isEqual:@"=>"]) {
        [self operator:@"=>" error:NULL];
        targetIdentifier = [self.restOfTokens componentsJoinedByString:@""];
    }
    {
    LayoutConstraint* constraint = [LayoutConstraint constraintWithItem:firstItem attribute:firstAttribute relatedBy:relation toItem:secondItem attribute:secondAttribute multiplier:multiplier constant:constant targetIdentifier:targetIdentifier];
    return constraint;
    }
}

- (NSArray*)restOfTokens
{
    NSArray* result = [self.tokens subarrayWithRange:NSMakeRange(self.cursor, self.tokens.count-self.cursor)];
    self.cursor = self.tokens.count;
    return result;
}

- (BOOL)isEOF
{
    return self.cursor == self.tokens.count;
}

- (NSLayoutRelation)relationWithError:(NSError**)error
{
    NSDictionary* relations = @{
       @"==": @(NSLayoutRelationEqual),
       @">=": @(NSLayoutRelationGreaterThanOrEqual),
       @"<=": @(NSLayoutRelationLessThanOrEqual)
    };
    NSString* peek = [self peek];
    if ([relations.allKeys containsObject:peek]) {
        self.cursor++;
        return (NSLayoutRelation)[relations[peek] integerValue];
    }
    NSString* reason = @"Expected relation";
    *error = fail(reason);
    return 0;
}

- (CGFloat)parseFloatWithError:(NSError**)error
{
    id peek = self.peek;
    if ([peek isKindOfClass:[NSNumber class]]) {
        self.cursor++;
        return [peek doubleValue];
    }
    NSString* reason = [NSString stringWithFormat:@"Expected number, saw: %@", peek];
    *error = fail(reason);
    return 0;
}

- (NSLayoutAttribute)attributeWithError:(NSError**)error
{
    NSString* peek = [self peek];
    if ([self.attributes.allKeys containsObject:peek]) {
        self.cursor++;
        return (NSLayoutAttribute)[self.attributes[peek] integerValue];
    }
    NSString* reason = [NSString stringWithFormat:@"Expected layout attributeWithError:, saw: %@", peek];
    *error = fail(reason);
    return 0;
}

- (void)operator:(NSString*)string error:(NSError**)error
{
    NSString* peek = [self peek];
    if ([peek isEqual:string]) {
        self.cursor++;
        return;
    }
    NSString* reason = [NSString stringWithFormat:@"Expected: %@, saw: %@", string, peek];
    *error = fail(reason);
}

- (NSArray*)objcExpression:(NSError**)error
{
    NSString* initial = [self variable:error];
    RETURN_NIL_IF_ERROR
    [self operator:@"." error:error];
    RETURN_NIL_IF_ERROR
    NSMutableArray* array = [NSMutableArray arrayWithObject:initial];
    while(![self.attributes.allKeys containsObject:self.peek]) {
        [array addObject:[self variable:error ]];
        RETURN_NIL_IF_ERROR
        [self operator:@"." error:error];
        RETURN_NIL_IF_ERROR
    }
    return [array copy];
}

- (NSString*)variable:(NSError**)error
{
    id peek = [self peek];
    if ([peek isKindOfClass:[NSString class]]) {
        self.cursor++;
        return peek;
    }
    NSString* reason = [NSString stringWithFormat: @"Parse error: %lu - %@", self.cursor, [self.tokens componentsJoinedByString:@" "]];
    *error = fail(reason);
    return nil;
}

- (id)peek
{
    if (self.cursor >= self.tokens.count) return nil;

    id peek = self.tokens[self.cursor];
    return peek;
}

@end
