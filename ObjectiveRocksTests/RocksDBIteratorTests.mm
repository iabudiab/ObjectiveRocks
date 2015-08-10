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

- (void)testDB_Iterator_Seek
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];

	RocksDBIterator *iterator = [_rocks iterator];

	[iterator seekToFirst];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"key 1"));
	XCTAssertEqualObjects(iterator.value, Data(@"value 1"));

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"key 2"));
	XCTAssertEqualObjects(iterator.value, Data(@"value 2"));

	[iterator next];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToLast];
	[iterator previous];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"key 1"));
	XCTAssertEqualObjects(iterator.value, Data(@"value 1"));

	[iterator seekToFirst];
	[iterator seekToLast];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"key 2"));
	XCTAssertEqualObjects(iterator.value, Data(@"value 2"));

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
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

- (void)testDB_Iterator_EnumerateKeys_RangeStart
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksDBMakeKeyRange(Data(@"key 2"), nil) reverse:NO usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksDBMakeKeyRange(nil, Data(@"key 4")) reverse:NO usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysInRange:RocksDBMakeKeyRange(Data(@"key 2"), Data(@"key 4")) reverse:NO usingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeys_Encoded
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.keyType = RocksDBTypeNSString;
		options.valueType = RocksDBTypeNSString;
	}];

	[_rocks setObject:@"value 1" forKey:@"Key 1"];
	[_rocks setObject:@"value 2" forKey:@"Key 2"];
	[_rocks setObject:@"value 3" forKey:@"Key 3"];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:key];
	}];

	NSArray *expected = @[ @"Key 1", @"Key 2", @"Key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesUsingBlock:^(id key, id value, BOOL *stop) {
		[actual addObject:Str(key)];
		[actual addObject:Str(value)];
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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInReverse:YES usingBlock:^(id key, id value, BOOL *stop) {
		[actual addObject:Str(key)];
		[actual addObject:Str(value)];
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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInRange:RocksDBMakeKeyRange(Data(@"key 2"), nil)
									reverse:NO
								 usingBlock:^(id key, id value, BOOL *stop) {
									 [actual addObject:Str(key)];
									 [actual addObject:Str(value)];
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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInRange:RocksDBMakeKeyRange(nil, Data(@"key 4"))
									reverse:NO
								 usingBlock:^(id key, id value, BOOL *stop) {
									 [actual addObject:Str(key)];
									 [actual addObject:Str(value)];
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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[_rocks setData:Data(@"value 4") forKey:Data(@"key 4")];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesInRange:RocksDBMakeKeyRange(Data(@"key 2"), Data(@"key 4"))
									reverse:NO
								 usingBlock:^(id key, id value, BOOL *stop) {
									 [actual addObject:Str(key)];
									 [actual addObject:Str(value)];
								 }];


	NSArray *expected = @[ @"key 2", @"value 2", @"key 3", @"value 3" ];
	XCTAssertEqualObjects(actual, expected);

	[iterator close];
}

- (void)testDB_Iterator_EnumerateKeysAndValues_Encoded
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.keyType = RocksDBTypeNSString;
		options.valueType = RocksDBTypeNSString;
	}];

	[_rocks setObject:@"value 1" forKey:@"Key 1"];
	[_rocks setObject:@"value 2" forKey:@"Key 2"];
	[_rocks setObject:@"value 3" forKey:@"Key 3"];

	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysAndValuesUsingBlock:^(id key, id value, BOOL *stop) {
		[actual addObject:key];
		[actual addObject:value];
	}];

	NSArray *expected = @[ @"Key 1", @"value 1", @"Key 2", @"value 2", @"Key 3", @"value 3" ];
	XCTAssertEqualObjects(actual, expected);
	
	[iterator close];
}

@end
