//
//  BLCCommentTests.m
//  Blocstagram
//
//  Created by Andrew Carvajal on 5/17/15.
//  Copyright (c) 2015 graffme, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Comment.h"

@interface BLCCommentTests : XCTestCase

@end

@implementation BLCCommentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatInitializationWorks {
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"text": @"Sample Comment"};
    Comment *testComment = [[Comment alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testComment.idNumber, sourceDictionary[@"id"], @"The id should be equal.");
    XCTAssertEqualObjects(testComment.text, sourceDictionary[@"text"], @"The test should be equal.");
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
