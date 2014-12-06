//
//  RocksDBSnapshotTests.m
//  BCRocks
//
//  Created by Iska on 06/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Str(x)	[[NSString alloc] initWithData:x encoding:NSUTF8StringEncoding]

@interface RocksDBSnapshotTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBSnapshotTests

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

- (void)testSnapshot
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];
	[_rocks setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[_rocks setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	RocksDBSnapshot *snapshot = [_rocks snapshot];

	[_rocks deleteDataForKey:Data(@"Key 1")];
	[_rocks setData:Data(@"Value 4") forKey:Data(@"Key 4")];

	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 4")], nil);

	[snapshot close];

	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 1")], nil);
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 4")], Data(@"Value 4"));
}

- (void)testSnapshot_Iterator
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];
	[_rocks setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[_rocks setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	RocksDBSnapshot *snapshot = [_rocks snapshot];

	[_rocks deleteDataForKey:Data(@"Key 1")];
	[_rocks setData:Data(@"Value 4") forKey:Data(@"Key 4")];


	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [snapshot iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"Key 1", @"Key 2", @"Key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[snapshot close];

	[actual removeAllObjects];
	iterator = [snapshot iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	expected = @[ @"Key 2", @"Key 3", @"Key 4" ];
	XCTAssertEqualObjects(actual, expected);
}

@end
