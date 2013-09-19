//
//  ParserTests.m
//  constraintsparser
//
//  Created by Chris Eidhof on 9/19/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Parser.h"
#import "LayoutConstraint.h"

@interface ParserTests : XCTestCase

@property (nonatomic,strong) Parser* parser;

@end

@implementation ParserTests

- (void)setUp
{
    [super setUp];
    self.parser = [Parser new];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSimpleEquality
{
    id result = [self.parser parse:@"a.width == b.height" error:NULL ];
    id expected = [LayoutConstraint constraintWithItem:@[@"a"] attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:@[@"b"] attribute:NSLayoutAttributeHeight multiplier:1 constant:0 targetIdentifier:nil ];
    XCTAssertEqualObjects(result, expected, @"Simple equation");
}

- (void)testMultiplier
{
    id result = [self.parser parse:@"self.baseline >= test.hi.centerX * 2.3" error:NULL ];
    id expected = [LayoutConstraint constraintWithItem:@[@"self"] attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:@[@"test", @"hi"] attribute:NSLayoutAttributeCenterX multiplier:2.3 constant:0 targetIdentifier:nil ];
    XCTAssertEqualObjects(result, expected, @"should be able to parse multipliers");
}

- (void)testDotNotation
{
    id result = [self.parser parse:@"self.one.two.baseline <= test.centerX * 2.3" error:NULL ];
    id expected = [LayoutConstraint constraintWithItem:@[@"self", @"one", @"two"] attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationLessThanOrEqual toItem:@[@"test"] attribute:NSLayoutAttributeCenterX multiplier:2.3 constant:0 targetIdentifier:nil ];
    XCTAssertEqualObjects(result, expected, @"should be able to parse dot notation");
}

- (void)testConstants
{
    id result = [self.parser parse:@"a12.baseline <= 10 + test.centerX * 0.5" error:NULL ];
    id expected = [LayoutConstraint constraintWithItem:@[@"a12"] attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationLessThanOrEqual toItem:@[@"test"] attribute:NSLayoutAttributeCenterX multiplier:0.5 constant:10 targetIdentifier:nil ];
    XCTAssertEqualObjects(result, expected, @"should be able to parse dot notation");
}

- (void)testWithoutAttribute
{
    id result = [self.parser parse:@"x.width == 200" error:NULL];
    id expected = [LayoutConstraint constraintWithItem:@[@"x"] attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200 targetIdentifier:nil ];
    XCTAssertEqualObjects(result, expected, @"should be able to parse constant expressions");
}

- (void)testAssignment
{
    id result = [self.parser parse:@"x.centerY == 200 => self.centerConstraint" error:NULL];
    NSString* targetIdentifier = @"self.centerConstraint";
    id expected = [LayoutConstraint constraintWithItem:@[@"x"] attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200 targetIdentifier:targetIdentifier];
    XCTAssertEqualObjects(result, expected, @"Should be able to assign statements");
}

- (void)testError {
    NSError* error;
    id result = [self.parser parse:@"test" error:&error];
    XCTAssertNil(result, @"Shouldn't be able to parse");
    XCTAssertNotNil(error, @"Should have an error");
}

- (void)testTokenizeError {
    NSError* error;
    id result = [self.parser parse:@";" error:&error];
    XCTAssertNil(result, @"Should have no result");
    XCTAssertNotNil(error, @"Should have an error");
}

@end
