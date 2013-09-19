//
// Created by Florian on 18.09.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ConstraintFormula.h"
#import "Parser.h"
#import "LayoutConstraint.h"
#import "Configuration.h"



static int constraintCounter = 0;

@implementation ConstraintFormula {

}

- (instancetype)initWithLine:(NSString *)line
{
    self = [super init];
    if (self) {
        self.line = line;
        self.priority = @1000;
        self.constant = @0;
        self.multiplier = @1;
        self.identifier = [NSString stringWithFormat:@"objcio__constraint%d", constraintCounter++];
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
        self.attribute1 = constraint.firstAttribute;
        self.attribute2 = constraint.secondAttribute;
        self.multiplier = constraint.multiplier;
        self.constant = constraint.constant;
        self.priority = constraint.priority;
        self.relation = constraint.relation;
        self.targetIdentifier = constraint.targetIdentifier;
    }
}

- (NSString *)layoutConstraintCode
{
    NSString *attribute1 = [self attributeIdentifierForAttribute:self.attribute1];
    NSString *attribute2 = [self attributeIdentifierForAttribute:self.attribute2];
    NSString *relation = [self relationIdentifierForRelation:self.relation];
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:
                      @"NSLayoutConstraint *%@ = [NSLayoutConstraint constraintWithItem:%@ attribute:%@ relatedBy:%@ toItem:%@ attribute:%@ multiplier:%@ constant:%@];",
                      self.identifier,
                      (self.view1 == nil) ? @"nil" : self.view1, attribute1, relation,
                      (self.view2 == nil) ? @"nil" : self.view2, attribute2, self.multiplier, self.constant]];
    [lines addObject:[NSString stringWithFormat:@"%@.priority = %@;", self.identifier, self.priority]];
    if (self.targetIdentifier) {
        [lines addObject:[NSString stringWithFormat:@"%@ = %@;", self.targetIdentifier, self.identifier]];
    }
    if ([Configuration shouldAddDebugInfo]) {
        [lines addObjectsFromArray:[self codeForAssociatingInputLineWithConstraintIdentifier:self.identifier]];
    }
    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)relationIdentifierForRelation:(NSLayoutRelation)relation
{
    NSString *relationIdentifier = @"";
    switch (relation) {
        case NSLayoutRelationGreaterThanOrEqual:
            relationIdentifier = @"NSLayoutRelationGreaterThanOrEqual";
            break;
        case NSLayoutRelationLessThanOrEqual:
            relationIdentifier = @"NSLayoutRelationLessThanOrEqual";
            break;
        case NSLayoutRelationEqual:
            relationIdentifier = @"NSLayoutRelationEqual";
            break;
    }
    return relationIdentifier;
}

- (NSString *)attributeIdentifierForAttribute:(NSLayoutAttribute)attribute
{
    NSString *attributeIdentifier = @"";
    switch (attribute) {
        case NSLayoutAttributeCenterX:
            attributeIdentifier = @"NSLayoutAttributeCenterX";
            break;
        case NSLayoutAttributeHeight:
            attributeIdentifier = @"NSLayoutAttributeHeight";
            break;
        case NSLayoutAttributeTop:
            attributeIdentifier = @"NSLayoutAttributeTop";
            break;
        case NSLayoutAttributeBaseline:
            attributeIdentifier = @"NSLayoutAttributeBaseline";
            break;
        case NSLayoutAttributeBottom:
            attributeIdentifier = @"NSLayoutAttributeBottom";
            break;
        case NSLayoutAttributeCenterY:
            attributeIdentifier = @"NSLayoutAttributeCenterY";
            break;
        case NSLayoutAttributeLeading:
            attributeIdentifier = @"NSLayoutAttributeLeading";
            break;
        case NSLayoutAttributeLeft:
            attributeIdentifier = @"NSLayoutAttributeLeft";
            break;
        case NSLayoutAttributeNotAnAttribute:
            attributeIdentifier = @"NSLayoutAttributeNotAnAttribute";
            break;
        case NSLayoutAttributeRight:
            attributeIdentifier = @"NSLayoutAttributeRight";
            break;
        case NSLayoutAttributeTrailing:
            attributeIdentifier = @"NSLayoutAttributeTrailing";
            break;
        case NSLayoutAttributeWidth:
            attributeIdentifier = @"NSLayoutAttributeWidth";
            break;
    }
    return attributeIdentifier;
}

- (NSArray *)codeForAssociatingInputLineWithConstraintIdentifier:(NSString *)constraintIdentifier;
{
    NSString *code = self.line;
    code = [code stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    id line1 = [NSString stringWithFormat:@"[%@ objcio_associateSourceCodeString:@\"%@\"];", self.identifier, code];
    if (self.fileAndLineDescription == nil) {
        return @[line1];
    }
    id line2 = [NSString stringWithFormat:@"[%@ objcio_associateSourceCodeFileAndLine:@\"%@\"];", self.identifier, self.fileAndLineDescription];
    return @[line1, line2];
}

@end
