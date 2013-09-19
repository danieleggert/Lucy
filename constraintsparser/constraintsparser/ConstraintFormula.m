//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ConstraintFormula.h"


static int constraintCounter = 0;

@implementation ConstraintFormula {

}

- (instancetype)initWithTargetIdentifier:(NSString *)targetIdentifier formula:(NSString *)formula
{
    self = [super init];
    if (self) {
        self.formula = formula;
        self.targetIdentifier = targetIdentifier;
        self.priority = 1000;
        self.constant = 0;
        self.multiplier = 1;
    }
    return self;
}

- (void)parse
{
    self.view1 = @"view1";
    self.view2 = @"view2";
    self.multiplier = 1;
    self.constant = 0;
    self.priority = 1000;
}

- (NSString *)layoutConstraintCodeForSuperview:(NSString *)superview
{
    constraintCounter++;
    NSString *constraintIdentifier = [NSString stringWithFormat:@"objcio__constraint%d", constraintCounter];
    NSMutableArray *lines = [@[
        [NSString stringWithFormat:@"%@.translatesAutoResizingMaskIntoConstraints = NO;\n", self.view1],
        [NSString stringWithFormat:@"%@.translatesAutoResizingMaskIntoConstraints = NO;\n", self.view2],
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