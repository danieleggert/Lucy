//
//  ConstraintFormulaTests.m
//  constraintsparser
//
//  Created by Florian on 19.09.13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AutoLayoutCommentProcessor.h"


@interface AutoLayoutCommentProcessorTests : XCTestCase

@end

@implementation AutoLayoutCommentProcessorTests

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

- (void)testCommentParsing
{
    NSString *comment = @"superview: self.view\n"
        "a.width == b.width\n"
        "b.top == c.top + 20 => self.testConstraint";
    NSArray *lines = [comment componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    AutoLayoutCommentProcessor *processor = [[AutoLayoutCommentProcessor alloc] init];
    NSArray *output = [processor processedLinesFromLines:lines errorHandler:nil];
    NSLog(@"%@", output);
    XCTFail(@"");
}

@end
