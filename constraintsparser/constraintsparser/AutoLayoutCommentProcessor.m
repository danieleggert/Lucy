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
        self.superviewIdentifier = @"self.view";
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
        [lines addObject:[formula layoutConstraintCode]];
    }
    [lines addObjectsFromArray:self.codeForDisablingTranslatesAutoResizingMask];
    [lines addObject:self.codeForAddingConstraintsToSuperview];
    return [lines copy];
}

- (NSString *)codeForAddingConstraintsToSuperview
{
    NSMutableArray *constraintIdentifiers = [NSMutableArray array];
    for (ConstraintFormula *formula in self.formulas) {
        [constraintIdentifiers addObject:formula.identifier];
    }
    NSString *viewList = [constraintIdentifiers componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"[%@ addConstraints:@[%@]];", self.superviewIdentifier, viewList];
}

- (NSArray *)codeForDisablingTranslatesAutoResizingMask
{
    NSMutableSet *viewIdentifiers = [NSMutableSet set];
    for (ConstraintFormula *formula in self.formulas) {
        [viewIdentifiers addObject:formula.view1];
        [viewIdentifiers addObject:formula.view2];
    }
    NSMutableArray *lines = [NSMutableArray array];
    for (NSString *viewIdentifier in viewIdentifiers) {
        if (!viewIdentifier.length) continue;
        [lines addObject:[NSString stringWithFormat:@"%@.translatesAutoResizingMaskIntoConstraints = NO;", viewIdentifier]];
    }
    return lines;
}

- (void)processLine:(NSString *)line index:(NSUInteger)idx
{
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    ConstraintFormula *constraintFormula = [[ConstraintFormula alloc] initWithLine:line];
    NSError *parseError;
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