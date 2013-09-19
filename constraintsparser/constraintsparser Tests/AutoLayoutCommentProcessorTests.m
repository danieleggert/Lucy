//
//  AutoLayoutCommentProcessorTests.m
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

- (void)testParseComment
{
    NSString *comment = @"superview: self.view\n"
    "\n"
    "self.one.two.baseline <= test.centerX * 2.3\n"
    "self.one.two.top <= test.bottom => self.constraint2";
    NSArray *commentLines = [comment componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    AutoLayoutCommentProcessor *processor = [[AutoLayoutCommentProcessor alloc] init];
    NSArray *output = [processor processedLinesFromLines:commentLines errorHandler:nil];
    XCTAssert(output.count > 0);
}

@end
