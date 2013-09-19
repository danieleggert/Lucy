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
#import "Expression.h"

#define RETURN_NIL_IF_ERROR if (error && *error) return nil;

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
    NSError* theError;
    Tokenizer* tokenizer = [Tokenizer new];
    self.tokens = [tokenizer tokenize:string error:error ];
    RETURN_NIL_IF_ERROR
    if (self.tokens.count == 0) {
        *error = fail(@"No tokens");
        return nil;
    }
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
    id constant = @(0);
    id multiplier = @(1);
    id peek = self.peek;
    if ([peek isKindOfClass:[NSNumber class]] || [peek isKindOfClass:[Expression class]]) {
        constant = [self parseFloatOrVariableWithError:error];
        RETURN_NIL_IF_ERROR
        if (![self.peek isEqual:@"+"]) goto end;
        [self operator:@"+" error:error];
        RETURN_NIL_IF_ERROR
    }

    secondItem = [self objcExpression:error];
    RETURN_NIL_IF_ERROR

    secondAttribute = [self attributeWithError:error ];
    RETURN_NIL_IF_ERROR
    if ([self.peek isEqual:@"*"]) {
        [self operator:@"*" error:error ];
        RETURN_NIL_IF_ERROR
        multiplier = [self parseFloatOrVariableWithError:NULL ];
        RETURN_NIL_IF_ERROR
    }
end: {
    LayoutConstraint* constraint = [LayoutConstraint constraintWithItem:firstItem attribute:firstAttribute relatedBy:relation toItem:secondItem attribute:secondAttribute multiplier:multiplier constant:constant targetIdentifier:nil];
    if ([self.peek isEqual:@"@"]) {
        [self operator:@"@" error:NULL];
        id priority = [self parseFloatOrVariableWithError:error];
        RETURN_NIL_IF_ERROR
        constraint.priority = priority;
    }
    if ([self.peek isEqual:@"=>"]) {
        [self operator:@"=>" error:NULL];
        constraint.targetIdentifier = [self.restOfTokens componentsJoinedByString:@""];
    }

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

- (id)parseFloatOrVariableWithError:(NSError**)error
{
    id peek = self.peek;
    if ([peek isKindOfClass:[NSNumber class]]) {
        return [self parseFloatWithError:error];
    } else {
        return [self parseExpression:error];
    }
}

- (id)parseExpression:(NSError**)error
{
    id peek = self.peek;
    if ([peek isKindOfClass:[Expression class]]) {
        self.cursor++;
        return [peek expression];
    }
    *error = fail(@"Expected expression");
    return nil;
 }

- (id)parseFloatWithError:(NSError**)error
{
    id peek = self.peek;
    if ([peek isKindOfClass:[NSNumber class]]) {
        self.cursor++;
        return peek;
    }
    NSString* reason = [NSString stringWithFormat:@"Expected number, saw: %@", peek];
    *error = fail(reason);
    return nil;
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
