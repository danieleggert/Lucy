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

- (void)testWidthEqualsConstant
{
    [self testFormulaString:@"a.width == 200"
                    forItem:@"a"
                  attribute:@"NSLayoutAttributeWidth"
                   relation:@"NSLayoutRelationEqual"
                       item:@"nil"
                  attribute:@"NSLayoutAttributeNotAnAttribute"
                 multiplier:1
                   constant:200
                   priority:1000];
}

- (void)testWidthWithPriority
{
    [self testFormulaString:@"a.width == 200 @500"
                    forItem:@"a"
                  attribute:@"NSLayoutAttributeWidth"
                   relation:@"NSLayoutRelationEqual"
                       item:@"nil"
                  attribute:@"NSLayoutAttributeNotAnAttribute"
                 multiplier:1
                   constant:200
                   priority:500];
}

- (void)testWidthEqualToWidth
{
    [self testFormulaString:@"a.width == b.width"
                    forItem:@"a"
                  attribute:@"NSLayoutAttributeWidth"
                   relation:@"NSLayoutRelationEqual"
                       item:@"b"
                  attribute:@"NSLayoutAttributeWidth"
                 multiplier:1
                   constant:0
                   priority:1000];
}

- (void)testWidthEqualToWidthWithMultiplierAndConstant
{
    [self testFormulaString:@"a.width == 200 + b.width * 10"
                    forItem:@"a"
                  attribute:@"NSLayoutAttributeWidth"
                   relation:@"NSLayoutRelationEqual"
                       item:@"b"
                  attribute:@"NSLayoutAttributeWidth"
                 multiplier:10
                   constant:200
                   priority:1000];
}

- (void)testLeftToRightWithMultiplierConstantPriority
{
    [self testFormulaString:@"self.view.subview.left == 200 + self.view.subview2.right * 10@500"
                    forItem:@"self.view.subview"
                  attribute:@"NSLayoutAttributeLeft"
                   relation:@"NSLayoutRelationEqual"
                       item:@"self.view.subview2"
                  attribute:@"NSLayoutAttributeRight"
                 multiplier:10
                   constant:200
                   priority:500];
}

- (void)testFormulaString:(NSString *)formulaString forItem:(NSString *)item1 attribute:(NSString *)attribute1 relation:(NSString *)relation item:(NSString *)item2 attribute:(NSString *)attribute2 multiplier:(CGFloat)multiplier constant:(CGFloat)constant priority:(NSInteger)priority
{
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:formulaString];
    [formula parse:NULL];
    NSString *expectedOutput = [self expectedOutputForItem:item1 attribute:attribute1 relation:relation item:item2 attribute:attribute2 multiplier:multiplier constant:constant identifier:formula.identifier priority:priority];
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
