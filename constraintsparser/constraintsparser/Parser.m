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


- (LayoutConstraint*)parse:(NSString*)string error:(NSError**)error
{
    Tokenizer* tokenizer = [Tokenizer new];
    self.tokens = [tokenizer tokenize:string];
    self.cursor = 0;
    @try {
        return [self parseEquation];
    } @catch (NSException* e) {
        *error = [NSError errorWithDomain:@"io.objc" code:NSURLErrorUnknown userInfo:@{
          NSLocalizedDescriptionKey: e.reason
        }];
        return nil;
    }
}

- (LayoutConstraint*)parseEquation
{
    NSArray* firstItem = [self objcExpression];
    NSLayoutAttribute firstAttribute = [self attribute];
    NSLayoutRelation relation = [self relation];

    CGFloat constant = 0;
    if ([self.peek isKindOfClass:[NSNumber class]]) {
        constant = [self parseFloat];
        [self operator:@"+"];
    }

    NSArray* secondItem = [self objcExpression];

    NSLayoutAttribute secondAttribute = [self attribute];
    CGFloat multiplier = 1;
    if ([self.peek isEqual:@"*"]) {
        [self operator:@"*"];
        multiplier = [self parseFloat];
    }
    return [LayoutConstraint constraintWithItem:firstItem attribute:firstAttribute relatedBy:relation toItem:secondItem attribute:secondAttribute multiplier:multiplier constant:constant];
}

- (NSLayoutRelation)relation
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
    @throw [NSException exceptionWithName:@"expectedLayoutAttribute" reason:@"Expected layout attribute" userInfo:nil];
}

- (CGFloat)parseFloat
{
    id peek = self.peek;
    if ([peek isKindOfClass:[NSNumber class]]) {
        self.cursor++;
        return [peek doubleValue];
    }
    NSAssert(@NO, @"Expected number, saw: %@", peek);
    return 0;
}

- (NSLayoutAttribute)attribute
{
    NSString* peek = [self peek];
    if ([self.attributes.allKeys containsObject:peek]) {
        self.cursor++;
        return (NSLayoutAttribute)[self.attributes[peek] integerValue];
    }
    NSAssert(NO,@"Expected layout attribute, saw: %@", peek);
    return 0;
}

- (void)operator:(NSString*)string
{
    NSString* peek = [self peek];
    if ([peek isEqual:string]) {
        self.cursor++;
        return;
    }
    NSString* reason = [NSString stringWithFormat:@"Expected: %@, saw: %@", string, peek];
    @throw [NSException exceptionWithName:@"expectedOperator" reason:reason userInfo:nil];
}

- (NSArray*)objcExpression
{
    NSString* initial = [self variable];
    [self operator:@"."];
    NSMutableArray* array = [NSMutableArray arrayWithObject:initial];
    while(![self.attributes.allKeys containsObject:self.peek]) {
        [array addObject:[self variable]];
        [self operator:@"."];
    }
    return [array copy];
}

- (NSString*)variable
{
    id peek = [self peek];
    if ([peek isKindOfClass:[NSString class]]) {
        self.cursor++;
        return peek;
    }
    NSString* reason = [NSString stringWithFormat: @"Parse error: %lu - %@", self.cursor, self.tokens];
    @throw [NSException exceptionWithName:@"variableParseError" reason:reason userInfo:nil];
}

- (id)peek
{
    if (self.cursor >= self.tokens.count) return nil;

    id peek = self.tokens[self.cursor];
    return peek;
}

@end
