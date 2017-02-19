//
//  RocksDBIteratorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 04/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBIteratorTests : RocksDBTests

@end

@implementation RocksDBIteratorTests

- (void)testDB_Iterator
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	for ([iterator seekToFirst]; [iterator isValid]; [iterator next]) {
		[actual addObject:[[NSString alloc] initWithData:iterator.key]];
	}

	NSArray *expected = @[ @"key 1", @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_Seek
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];

	RocksDBIterator *iterator = [_rocks iterator];

	[iterator seekToFirst];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"key 1".data);
	XCTAssertEqualObjects(iterator.value, @"value 1".data);

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"key 2".data);
	XCTAssertEqualObjects(iterator.value, @"value 2".data);

	[iterator next];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToLast];
	[iterator previous];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"key 1".data);
	XCTAssertEqualObjects(iterator.value, @"value 1".data);

	[iterator seekToFirst];
	[iterator seekToLast];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"key 2".data);
	XCTAssertEqualObjects(iterator.value, @"value 2".data);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	NSArray *expected = @[ @"key 1", @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys_Reverse
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInReverse:YES usingBlock:^(NSData *key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	NSArray *expected = @[ @"key 3", @"key 2", @"key 1" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys_RangeStart
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[_rocks setData:@"value 4".data forKey:@"key 4".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksDBMakeKeyRange(@"key 2".data, nil) reverse:NO usingBlock:^(NSData *key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	NSArray *expected = @[ @"key 2", @"key 3", @"key 4" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys_RangeEnd
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[_rocks setData:@"value 4".data forKey:@"key 4".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksDBMakeKeyRange(nil, @"key 4".data) reverse:NO usingBlock:^(NSData *key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	NSArray *expected = @[ @"key 1", @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys_RangeStartEnd
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[_rocks setData:@"value 4".data forKey:@"key 4".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksDBMakeKeyRange(@"key 2".data, @"key 4".data) reverse:NO usingBlock:^(NSData *key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	NSArray *expected = @[ @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesUsingBlock:^(NSData *key, NSData *value, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
		[actual addObject:[[NSString alloc] initWithData:value]];
	}];

	NSArray *expected = @[ @"key 1", @"value 1", @"key 2", @"value 2", @"key 3", @"value 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues_Reverse
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInReverse:YES usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
		[actual addObject:[[NSString alloc] initWithData:value]];
	}];

	NSArray *expected = @[ @"key 3", @"value 3", @"key 2", @"value 2", @"key 1", @"value 1" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues_RangeStart
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[_rocks setData:@"value 4".data forKey:@"key 4".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInRange:RocksDBMakeKeyRange(@"key 2".data, nil)
									reverse:NO
								 usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
									 [actual addObject:[[NSString alloc] initWithData:key]];
									 [actual addObject:[[NSString alloc] initWithData:value]];
								 }];
	
	NSArray *expected = @[ @"key 2", @"value 2", @"key 3", @"value 3", @"key 4", @"value 4" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues_RangeEnd
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[_rocks setData:@"value 4".data forKey:@"key 4".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInRange:RocksDBMakeKeyRange(nil, @"key 4".data)
									reverse:NO
								 usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
									 [actual addObject:[[NSString alloc] initWithData:key]];
									 [actual addObject:[[NSString alloc] initWithData:value]];
								 }];
	
	NSArray *expected = @[ @"key 1", @"value 1", @"key 2", @"value 2", @"key 3", @"value 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues_RangeStartEnd
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[_rocks setData:@"value 4".data forKey:@"key 4".data error:nil];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInRange:RocksDBMakeKeyRange(@"key 2".data, @"key 4".data)
									reverse:NO
								 usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
									 [actual addObject:[[NSString alloc] initWithData:key]];
									 [actual addObject:[[NSString alloc] initWithData:value]];
								 }];


	NSArray *expected = @[ @"key 2", @"value 2", @"key 3", @"value 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

@end
