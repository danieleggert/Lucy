//
//  constraintsparser_Tests.m
//  constraintsparser Tests
//
//  Created by Daniel Eggert on 18/09/13.
//  Copyright (c) 2013 objc.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "CommentReplacer.h"



@interface CommentReplacerTests : XCTestCase
@end



@implementation CommentReplacerTests

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

- (void)testExample
{
    return;
    NSURL *fileURL = [[NSBundle bundleForClass:[CommentReplacerTests class]] URLForResource:@"TestFile" withExtension:@"mal"];
    XCTAssertNotNil(fileURL, @"");
    CommentReplacer *replacer = [CommentReplacer replacerForFileAtURL:fileURL];
    XCTAssertNotNil(replacer, @"");
    
    OCMockObject *mock = [OCMockObject mockForProtocol:@protocol(CommentParser)];
    [[[mock expect] andReturn:@[@"Replaced A", @"Replaced B"]] processedLinesFromLines:@[@"Original A", @"Original B", @"Original C"]];
    replacer.commentParser = (id) mock;
    
    NSData *output = [replacer processedFileData];
    NSURL *expectedOutputURL = [[NSBundle bundleForClass:[CommentReplacerTests class]] URLForResource:@"TestFile-output" withExtension:@"mal"];
    NSData *expectedOutput = [NSData dataWithContentsOfURL:expectedOutputURL];
    XCTAssertEqualObjects(output, expectedOutput, @"");
}

@end
