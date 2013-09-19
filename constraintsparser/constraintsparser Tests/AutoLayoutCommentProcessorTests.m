//
//  AutoLayoutCommentProcessorTests.m
//  constraintsparser
//
//  Created by Florian on 19.09.13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AutoLayoutCommentProcessor.h"
#import <Foundation/Foundation.h>

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
    "a.left = b.right => self.constraint1\n"
    "a.top = 2 * b.bottom + constant @501 => self.constraint2";
    
    AutoLayoutCommentProcessor *processor = [[AutoLayoutCommentProcessor alloc] initWithComment:comment];
    NSString *output = [processor process];
    NSArray *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    XCTAssert(lines.count > 0);
}

@end
