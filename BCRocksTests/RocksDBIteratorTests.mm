//
//  RocksDBIteratorTests.m
//  BCRocks
//
//  Created by Iska on 04/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Str(x)	[[NSString alloc] initWithData:x encoding:NSUTF8StringEncoding]

@interface RocksDBIteratorTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBIteratorTests

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

- (void)testDB_Iterator
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	for ([iterator seekToFirst]; [iterator isValid]; [iterator next]) {
		[actual addObject:Str([iterator key])];
	}

	NSArray *expected = @[ @"key 1", @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_Reverse
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInReverse:YES usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"key 3", @"key 2", @"key 1" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_RangeStart
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksMakeRange(Data(@"key 2"), nil) reverse:NO usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"key 2", @"key 3", @"key 4" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_RangeEnd
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksMakeRange(nil, Data(@"key 4")) reverse:NO usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"key 1", @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_RangeStartEnd
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksMakeRange(Data(@"key 2"), Data(@"key 4")) reverse:NO usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

@end
