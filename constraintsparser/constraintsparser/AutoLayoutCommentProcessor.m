//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AutoLayoutCommentProcessor.h"
#import "ConstraintFormula.h"


static NSString *const SuperViewPrefix = @"superview";


@interface AutoLayoutCommentProcessor ()

@property (nonatomic, copy) NSString *comment;
@property (nonatomic, strong) NSMutableDictionary *aliases;
@property (nonatomic) NSString *superviewIdentifier;
@property (nonatomic, strong) NSMutableArray *formulas;

@end


@implementation AutoLayoutCommentProcessor {

}

- (instancetype)initWithComment:(NSString *)comment
{
    self = [super init];
    if (self) {
        self.comment = comment;
        self.superviewIdentifier = nil;
        self.formulas = [NSMutableArray array];
    }
    return self;    
}

- (NSString *)process
{
    [self.comment enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [self processLine:line];
    }];
    NSLog(@"superview: %@", self.superviewIdentifier);
    NSLog(@"formulas: %@", self.formulas);
    NSString *code = self.code;
    NSLog(@"%@", code);
    return code;
}

- (NSString *)code
{
    NSMutableArray *lines = [NSMutableArray array];
    for (ConstraintFormula *formula in self.formulas) {
        [lines addObject:[formula layoutConstraintCodeForSuperview:self.superviewIdentifier]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

- (void)processLine:(NSString *)line
{
    if (!line.length) return;

    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(\\w+):\\s*(.+)\\s*$" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSTextCheckingResult *result = [expression matchesInString:line options:0 range:NSMakeRange(0, line.length)].lastObject;
    if (result) {
        NSString *key = [line substringWithRange:[result rangeAtIndex:1]];
        NSString *value = [line substringWithRange:[result rangeAtIndex:2]];
        [self setConfigurationValue:value forKey:key];
    } else {
        [self addFormulaForLine:line];
    }
}

- (void)addFormulaForLine:(NSString *)line
{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(.+)\\s*(?:=>\\s*(\\w+)\\s*)$" options:0 error:NULL];
    NSTextCheckingResult *result = [expression matchesInString:line options:0 range:NSMakeRange(0, line.length)].lastObject;
    NSString *formula = [line substringWithRange:[result rangeAtIndex:0]];
    NSString *targetIdentifier = result.numberOfRanges > 2 ? [line substringWithRange:[result rangeAtIndex:2]] : nil;
    ConstraintFormula *constraintFormula = [[ConstraintFormula alloc] initWithTargetIdentifier:targetIdentifier formula:formula];
    [constraintFormula parse];
    [self.formulas addObject:constraintFormula];
}

- (void)setConfigurationValue:(NSString *)value forKey:(NSString *)key
{
    key = [key lowercaseString];
    if ([key isEqualToString:SuperViewPrefix]) {
        self.superviewIdentifier = value;
    } else {
        // error
    }
}

@end