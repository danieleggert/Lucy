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

- (void)testParseComment
{
    ConstraintFormula *formula = [[ConstraintFormula alloc] initWithLine:nil];
    formula.view1 = @"self.one.two";
    formula.view2 = @"test";
    formula.relation = 0;
    formula.attribute1 = 1;
    formula.attribute2 = 1;
    formula.multiplier = 2.3;
    NSString *expectedOutput = @"self.one.two.translatesAutoresizingMaskIntoConstraints = NO;\n"
        "test.translatesAutoresizingMaskIntoConstraints = NO;\n"
        "NSLayoutConstraint *objcio__constraint1 = [NSLayoutConstraint constraintWithItem:self.one.two attribute:1 relatedBy:0 toItem:test attribute:1 multiplier:2.300000 constant:0.000000];\n"
        "objcio__constraint1.priority = 1000;\n"
        "[self.view addConstraint:objcio__constraint1];";
    NSString *output = [formula layoutConstraintCodeForSuperview:@"self.view"];
    NSLog(@"%@", output);
    XCTAssert([output isEqualToString:expectedOutput], @"output does not match expected output");
}

@end
