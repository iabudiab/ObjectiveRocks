//
//  RocksDBWriteBatchTests.m
//  BCRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]

@interface RocksDBWriteBatchTests : XCTestCase
{
	RocksDB *_rocks;
}
@end

@implementation RocksDBWriteBatchTests

- (void)setUp
{
	[super setUp];

	NSString * path = [[NSBundle bundleForClass:[self class]] resourcePath];
	path = [path stringByAppendingPathComponent:@"BCRocks"];
	_rocks = [[RocksDB alloc] initWithPath:path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
}

- (void)tearDown
{
	[_rocks close];

	NSString * path = [[NSBundle bundleForClass:[self class]] resourcePath];
	path = [path stringByAppendingPathComponent:@"BCRocks"];

	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	if (error) {
		NSLog(@"Error test teardown: %@", [error debugDescription]);
	}
	[super tearDown];
}


- (void)testExample
{
	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch setData:Data(@"Value 1") forKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

@end
