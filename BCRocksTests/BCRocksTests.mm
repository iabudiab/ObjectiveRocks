//
//  BCRocksTests.m
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BCRocks.h"

@interface BCRocksTests : XCTestCase

@end

@implementation BCRocksTests

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

- (void)testCompile
{
	BCRocks *rocks = [BCRocks new];

    XCTAssert(YES, @"Pass");
}

@end
