//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AutoLayoutCommentProcessor.h"
#import "ConstraintFormula.h"


static NSString *const SuperViewPrefix = @"superview";


@interface AutoLayoutCommentProcessor ()

@property (nonatomic) NSString *superviewIdentifier;
@property (nonatomic, strong) NSMutableArray *formulas;

@property (nonatomic, strong) id <LineErrorHandler> errorHandler;
@end


@implementation AutoLayoutCommentProcessor {

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.superviewIdentifier = nil;
        self.formulas = [NSMutableArray array];
    }
    return self;    
}


- (NSArray *)processedLinesFromLines:(NSArray *)inputLines errorHandler:(id <LineErrorHandler>)errorHandler
{
    self.errorHandler = errorHandler;
    [inputLines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        [self processLine:line index:idx];
    }];
    return self.code;
}

- (NSArray *)code
{
    NSMutableArray *lines = [NSMutableArray array];
    for (ConstraintFormula *formula in self.formulas) {
        [lines addObject:[formula layoutConstraintCodeForSuperview:self.superviewIdentifier]];
    }
    return [lines copy];
}

- (void)processLine:(NSString *)line index:(NSUInteger)idx
{
    if (!line.length) return;

    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(\\w+):\\s*(.+)\\s*$" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSTextCheckingResult *result = [expression matchesInString:line options:0 range:NSMakeRange(0, line.length)].lastObject;
    NSError *error;
    if (result) {
        NSString *key = [line substringWithRange:[result rangeAtIndex:1]];
        NSString *value = [line substringWithRange:[result rangeAtIndex:2]];
        [self setConfigurationValue:value forKey:key error:&error];
    } else {
        [self addFormulaForLine:line error:&error];
    }
    if (error) {
        [self.errorHandler logErrorString:error.userInfo[NSLocalizedDescriptionKey] forLineAtIndex:idx];
    }
}

- (void)addFormulaForLine:(NSString *)line error:(NSError **)error
{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^\\s*(.+)\\s*(?:=>\\s*(\\w+)\\s*)$" options:0 error:NULL];
    NSTextCheckingResult *result = [expression matchesInString:line options:0 range:NSMakeRange(0, line.length)].lastObject;
    NSString *formula = [line substringWithRange:[result rangeAtIndex:0]];
    NSString *targetIdentifier = result.numberOfRanges > 2 ? [line substringWithRange:[result rangeAtIndex:2]] : nil;
    ConstraintFormula *constraintFormula = [[ConstraintFormula alloc] initWithTargetIdentifier:targetIdentifier formula:formula];
    NSError * parseError;
    [constraintFormula parse:&parseError];
    if (parseError) {
        *error = parseError;
    } else {
        [self.formulas addObject:constraintFormula];
    }
}

- (void)setConfigurationValue:(NSString *)value forKey:(NSString *)key error:(NSError **)error
{
    key = [key lowercaseString];
    if ([key isEqualToString:SuperViewPrefix]) {
        self.superviewIdentifier = value;
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unknown configuration key: %@", key]};
        *error = [NSError errorWithDomain:@"io.objc" code:0 userInfo:userInfo];
    }
}


@end