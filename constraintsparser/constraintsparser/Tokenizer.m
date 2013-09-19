//
// Created by chris on 9/18/13.
//

#import "Tokenizer.h"
#import "Expression.h"


@interface Tokenizer ()

@property (nonatomic, strong) NSScanner* scanner;
@property (nonatomic, strong) NSMutableArray* tokens;
@end

@implementation Tokenizer


- (NSArray*)tokenize:(NSString*)string error:(NSError**)error
{
    self.scanner = [NSScanner scannerWithString:string];
    self.tokens = [NSMutableArray new];
    while (!self.scanner.isAtEnd) {
        BOOL scanSucceeded = [self scanOperator] || [self scanNumber] || [self scanIdentifier] || [self scanExpression];
        if (!scanSucceeded) {
            NSString* reason = [NSString stringWithFormat:@"Couldn't scan token: %@", [self.scanner.string substringFromIndex:self.scanner.scanLocation]];
            *error = fail(reason);
            return nil;
        }
    }
    return [self.tokens copy];
}

- (BOOL)scanExpression
{
    BOOL open = [self.scanner scanString:@"(" intoString:NULL];
    if (!open) return NO;

    NSString* result = nil;
    open = [self.scanner scanUpToString:@")" intoString:&result];
    if (open) {
        [self.tokens addObject:[Expression expressionWithExpression:result]];
        [self.scanner scanString:@")" intoString:NULL];
        return YES;
    }
    return NO;
}

- (BOOL)scanOperator
{
    NSArray* operators = @[@"==",@"<=",@">=",@"=>",@".",@"*",@"+",@"@"];
    for(NSString* operator in operators) {
        if([self.scanner scanString:operator intoString:NULL]) {
            [self.tokens addObject:operator];
            return YES;
        }
    }
    return NO;
}

- (BOOL)scanNumber
{
    double result;
    if([self.scanner scanDouble:&result]) {
        [self.tokens addObject:@(result)];
        return YES;
    }
    return NO;

}

- (BOOL)scanIdentifier
{
    NSString* token;
    if ([self.scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&token]) {
        [self.tokens addObject:token];
        return YES;
    }
    return NO;
}

@end
