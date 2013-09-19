//
// Created by chris on 9/18/13.
//

#import "LayoutConstraint.h"

@implementation LayoutConstraint

- (instancetype)initWithItem:(id)firstItem attribute:(NSLayoutAttribute)firstAttribute relatedBy:(NSLayoutRelation)relation toItem:(id)secondItem attribute:(NSLayoutAttribute)secondAttribute multiplier:(CGFloat)multiplier constant:(CGFloat)constant
{
    self = [super init];
    if (self) {
        self.firstItem = firstItem;
        self.firstAttribute=firstAttribute;
        self.relation=relation;
        self.secondItem=secondItem;
        self.secondAttribute=secondAttribute;
        self.multiplier=multiplier;
        self.constant=constant;
    }

    return self;
}

+ (instancetype)constraintWithItem:(id)firstItem attribute:(NSLayoutAttribute)firstAttribute relatedBy:(NSLayoutRelation)relation toItem:(id)secondItem attribute:(NSLayoutAttribute)secondAttribute multiplier:(CGFloat)multiplier constant:(CGFloat)constant
{
    return [[self alloc] initWithItem:firstItem attribute:firstAttribute relatedBy:relation toItem:secondItem attribute:secondAttribute multiplier:multiplier constant:constant];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
            return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
            return NO;
    }

    return [self isEqualToConstraint:other];
}

- (BOOL)isEqualToConstraint:(LayoutConstraint*)constraint
{
    if (self == constraint) {
            return YES;
    }
    if (constraint == nil) {
            return NO;
    }
    if (self.firstItem != constraint.firstItem && ![self.firstItem isEqual:constraint.firstItem]) {
            return NO;
    }
    if (self.firstAttribute != constraint.firstAttribute) {
            return NO;
    }
    if (self.relation != constraint.relation) {
            return NO;
    }
    if (self.secondItem != constraint.secondItem && ![self.secondItem isEqual:constraint.secondItem]) {
            return NO;
    }
    if (self.secondAttribute != constraint.secondAttribute) {
            return NO;
    }
    if (self.multiplier != constraint.multiplier) {
            return NO;
    }
    if (self.constant != constraint.constant) {
            return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [self.firstItem hash];
    hash = hash * 31u + self.firstAttribute;
    hash = hash * 31u + self.relation;
    hash = hash * 31u + [self.secondItem hash];
    hash = hash * 31u + self.secondAttribute;
    hash = hash * 31u + [[NSNumber numberWithDouble:self.multiplier] hash];
    hash = hash * 31u + [[NSNumber numberWithDouble:self.constant] hash];
    return hash;
}

- (NSString*)description
{
    NSMutableString* description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"firstItem=%@", self.firstItem];
    [description appendFormat:@", firstAttribute=%li", self.firstAttribute];
    [description appendFormat:@", relation=%li", self.relation];
    [description appendFormat:@", secondItem=%@", self.secondItem];
    [description appendFormat:@", secondAttribute=%li", self.secondAttribute];
    [description appendFormat:@", multiplier=%f", self.multiplier];
    [description appendFormat:@", constant=%f", self.constant];
    [description appendString:@">"];
    return description;
}


@end
