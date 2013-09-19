//
// Created by chris on 9/19/13.
//

#import "Expression.h"


@implementation Expression

- (instancetype)initWithExpression:(NSString*)expression
{
    self = [super init];
    if (self) {
        self.expression = expression;
    }

    return self;
}

+ (instancetype)expressionWithExpression:(NSString*)expression
{
    return [[self alloc] initWithExpression:expression];
}


@end
