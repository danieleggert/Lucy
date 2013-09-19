//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ConstraintFormula.h"
#import "Parser.h"
#import "LayoutConstraint.h"


static int constraintCounter = 0;

@implementation ConstraintFormula {

}

- (instancetype)initWithLine:(NSString *)line
{
    self = [super init];
    if (self) {
        self.line = line;
        self.priority = 1000;
        self.constant = 0;
        self.multiplier = 1;
    }
    return self;
}

- (void)parse:(NSError **)error
{
    Parser* parser = [Parser new];
    NSError*parserError;
    LayoutConstraint* constraint = [parser parse:self.line error:&parserError];
    if (parserError) {
        *error = parserError;
    } else {
        self.view1 = [constraint.firstItem componentsJoinedByString:@"."];
        self.view2 = [constraint.secondItem componentsJoinedByString:@"."];
        self.multiplier = constraint.multiplier;
        self.constant = constraint.constant;
        self.priority = 1000; // todo
        self.targetIdentifier = constraint.targetIdentifier;
    }
}

- (NSString *)layoutConstraintCodeForSuperview:(NSString *)superview
{
    constraintCounter++;
    NSString *constraintIdentifier = [NSString stringWithFormat:@"objcio__constraint%d", constraintCounter];
    NSMutableArray *lines = [@[
        [NSString stringWithFormat:@"%@.translatesAutoResizingMaskIntoConstraints = NO;", self.view1],
        [NSString stringWithFormat:@"%@.translatesAutoResizingMaskIntoConstraints = NO;", self.view2],
        [NSString stringWithFormat:@"NSLayoutConstraint *%@ = [NSLayoutConstraint "
                                       "constraintWithItem:%@ attribute:%li relatedBy:%li toItem:%@ attribute:%li multiplier:%f constant:%f];", constraintIdentifier, self.view1, self.attribute1, self.relation, self.view2, self.attribute2, self.multiplier, self.constant],
        [NSString stringWithFormat:@"%@.priority = %li;", constraintIdentifier, self.priority],
        [NSString stringWithFormat:@"[%@ addConstraint:%@];", superview, constraintIdentifier],
    ] mutableCopy];
    if (self.targetIdentifier) {
        [lines addObject:[NSString stringWithFormat:@"%@ = %@;", self.targetIdentifier, constraintIdentifier]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

@end
