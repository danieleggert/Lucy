//
// Created by chris on 9/18/13.
//

#import "Tokenizer.h"


@interface Tokenizer ()

@property (nonatomic, strong) NSScanner* scanner;
@property (nonatomic, strong) NSMutableArray* tokens;
@end

@implementation Tokenizer


- (NSArray*)tokenize:(NSString*)string
{
    self.scanner = [NSScanner scannerWithString:string];
    self.tokens = [NSMutableArray new];
    while (!self.scanner.isAtEnd) {
        BOOL scanned = [self scanOperator] || [self scanNumber] || [self scanIdentifier];
        NSAssert(scanned, @"Couldn't scan: %@", [self.scanner.string substringFromIndex:self.scanner.scanLocation]);
    }
    return [self.tokens copy];
}

- (BOOL)scanOperator
{
    NSArray* operators = @[@"==",@"<=",@">=",@".",@"*",@"+"];
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
