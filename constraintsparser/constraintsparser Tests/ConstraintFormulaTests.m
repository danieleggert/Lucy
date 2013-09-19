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
    NSString *formulaString = @"self.one.two.baseline <= test.centerX * 2.3\n";
    NSString *expectedOutput = @"self.one.two.translatesAutoResizingMaskIntoConstraints = NO;\n"
        "test.translatesAutoResizingMaskIntoConstraints = NO;\n"
        "NSLayoutConstraint *objcio__constraint1 = [NSLayoutConstraint constraintWithItem:self.one.two attribute:0 relatedBy:0 toItem:test attribute:0 multiplier:2.300000 constant:0.000000];\n"
        "objcio__constraint1.priority = 1000;\n"
        "[self.view addConstraint:objcio__constraint1];\n"
        "self.constraint = objcio__constraint1;";
    ConstraintFormula *formula = [[ConstraintFormula alloc] init];
    formula.formula = formulaString;
    formula.targetIdentifier = @"self.constraint";
    NSError *error;
    [formula parse:&error];
    XCTAssertNil(error, @"error");
    NSString *output = [formula layoutConstraintCodeForSuperview:@"self.view"];
    NSLog(@"%@", output);
    XCTAssert([output isEqualToString:expectedOutput], @"output does not match expected output");
}

@end
