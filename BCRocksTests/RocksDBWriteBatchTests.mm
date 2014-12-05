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
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBWriteBatchTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] resourcePath];
	_path = [_path stringByAppendingPathComponent:@"BCRocks"];
}

- (void)tearDown
{
	[_rocks close];

	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:_path error:&error];
	if (error) {
		NSLog(@"Error test teardown: %@", [error debugDescription]);
	}
	[super tearDown];
}

- (void)testWriteBatch
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

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

- (void)testWriteBatch_DeleteOps
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_ClearOps
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
		[batch clear];
		[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], Data(@"Value 4"));
}

@end
