//
//  ConstraintFormulaTests.m
//  constraintsparser
//
//  Created by Florian on 19.09.13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConstraintFormula.h"

@interface ConstraintFormulaTests : XCTestCase

@end

@implementation ConstraintFormulaTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWidthAsConstant
{
    NSString *formulaString = @"a.width == 200";
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:formulaString];
    [formula parse:NULL];
    NSString *expectedOutput = [self expectedOutputForItem:@"a" attribute:@"NSLayoutAttributeWidth" relation:@"NSLayoutRelationEqual" item:@"nil" attribute:@"NSLayoutAttributeNotAnAttribute" multiplier:1 constant:200 identifier:formula.identifier priority:1000];
    XCTAssertEqualObjects(formula.layoutConstraintCode, expectedOutput, @"Should match");
}

- (void)testWidthWithPriority
{
    NSString *formulaString = @"a.width == 200 @500";
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:formulaString];
    [formula parse:NULL];
    NSString *expectedOutput = [self expectedOutputForItem:@"a" attribute:@"NSLayoutAttributeWidth" relation:@"NSLayoutRelationEqual" item:@"nil" attribute:@"NSLayoutAttributeNotAnAttribute" multiplier:1 constant:200 identifier:formula.identifier priority:500];
    XCTAssertEqualObjects(formula.layoutConstraintCode, expectedOutput, @"Should match");
}

- (void)testWidthEqualToWidth
{
    NSString *formulaString = @"a.width == b.width";
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:formulaString];
    [formula parse:NULL];
    NSString *expectedOutput = [self expectedOutputForItem:@"a" attribute:@"NSLayoutAttributeWidth" relation:@"NSLayoutRelationEqual" item:@"b" attribute:@"NSLayoutAttributeWidth" multiplier:1 constant:0 identifier:formula.identifier priority:1000];
    XCTAssertEqualObjects(formula.layoutConstraintCode, expectedOutput, @"Should match");
}

- (void)testWidthEqualToWidthWithMultiplierAndConstant
{
    NSString *formulaString = @"a.width == 200 + b.width * 10";
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:formulaString];
    [formula parse:NULL];
    NSString *expectedOutput = [self expectedOutputForItem:@"a" attribute:@"NSLayoutAttributeWidth" relation:@"NSLayoutRelationEqual" item:@"b" attribute:@"NSLayoutAttributeWidth" multiplier:10 constant:200 identifier:formula.identifier priority:1000];
    XCTAssertEqualObjects(formula.layoutConstraintCode, expectedOutput, @"Should match");
}

- (void)testLeftToRightWithMultiplierConstantPriority
{
    NSString *formulaString = @"self.view.subview.left == 200 + self.view.subview2.right * 10@500";
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:formulaString];
    [formula parse:NULL];
    NSString *expectedOutput = [self expectedOutputForItem:@"self.view.subview" attribute:@"NSLayoutAttributeLeft" relation:@"NSLayoutRelationEqual" item:@"self.view.subview2" attribute:@"NSLayoutAttributeRight" multiplier:10 constant:200 identifier:formula.identifier priority:500];
    XCTAssertEqualObjects(formula.layoutConstraintCode, expectedOutput, @"Should match");
}

- (NSString *)expectedOutputForItem:(NSString *)item1 attribute:(NSString *)attribute1 relation:(NSString *)relation item:(NSString *)item2 attribute:(NSString *)attribute2 multiplier:(CGFloat)multiplier constant:(CGFloat)constant identifier:(NSString *)identifier priority:(NSInteger)priority
{
    NSArray *lines = @[
        [NSString stringWithFormat:@"NSLayoutConstraint *%@ = [NSLayoutConstraint constraintWithItem:%@ attribute:%@ relatedBy:%@ toItem:%@ attribute:%@ multiplier:%g constant:%g];",
                identifier, item1, attribute1, relation, item2, attribute2, multiplier, constant],
        [NSString stringWithFormat:@"%@.priority = %li;", identifier, priority]
    ];
    return [lines componentsJoinedByString:@"\n"];
}

@end


