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
    NSURL *fileURL = [[NSBundle bundleForClass:[CommentReplacerTests class]] URLForResource:@"TestFile" withExtension:@"mal"];
    NSURL *outputURL = [NSURL fileURLWithPath:@"foo/bar/output.m"];
    XCTAssertNotNil(fileURL, @"");
    CommentReplacer *replacer = [CommentReplacer replacerForFileAtURL:fileURL outputFileURL:outputURL];
    replacer.lineControlUsesFullPath = NO;
    XCTAssertNotNil(replacer, @"");
    
    OCMockObject *mock = [OCMockObject mockForProtocol:@protocol(CommentParser)];
    [[[mock expect] andReturn:@[
                                @"Replaced A",
                                @"Replaced B"]] processedLinesFromLines:@[@"",
                                                                          @"     a.left = b.right;",
                                                                          @"     a.width = 200;",
                                                                          @"     b.height = 32;",
                                                                          @"     "] errorHandler:(id) replacer];
    replacer.commentParser = (id) mock;
    
    NSData *output = [replacer processedFileData];
    NSURL *expectedOutputURL = [[NSBundle bundleForClass:[CommentReplacerTests class]] URLForResource:@"TestFile-output" withExtension:@"mal"];
    NSData *expectedOutput = [NSData dataWithContentsOfURL:expectedOutputURL];
    XCTAssertEqualObjects(output, expectedOutput, @"");
}

@end
