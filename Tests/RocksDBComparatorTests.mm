//
//  RocksDBComparatorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 04/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBComparatorTests : RocksDBTests

@end

@implementation RocksDBComparatorTests

- (void)testComparator_Native_Bytewise_Ascending
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseAscending];
	}];

	[_rocks setData:@"abc1".data forKey:@"abc1".data error:nil];
	[_rocks setData:@"abc2".data forKey:@"abc2".data error:nil];
	[_rocks setData:@"abc3".data forKey:@"abc3".data error:nil];

	RocksDBIterator *iterator = [_rocks iterator];

	[iterator seekToFirst];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc1".data);
	XCTAssertEqualObjects(iterator.value, @"abc1".data);

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc2".data);
	XCTAssertEqualObjects(iterator.value, @"abc2".data);

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc3".data);
	XCTAssertEqualObjects(iterator.value, @"abc3".data);

	[iterator next];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToLast];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc3".data);
	XCTAssertEqualObjects(iterator.value, @"abc3".data);

	[iterator seekToKey:@"abc".data];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc1".data);
	XCTAssertEqualObjects(iterator.value, @"abc1".data);

	[iterator close];
}

- (void)testComparator_Native_Bytewise_Descending
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseDescending];
	}];

	[_rocks setData:@"abc1".data forKey:@"abc1".data error:nil];
	[_rocks setData:@"abc2".data forKey:@"abc2".data error:nil];
	[_rocks setData:@"abc3".data forKey:@"abc3".data error:nil];

	RocksDBIterator *iterator = [_rocks iterator];

	[iterator seekToFirst];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc3".data);
	XCTAssertEqualObjects(iterator.value, @"abc3".data);

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc2".data);
	XCTAssertEqualObjects(iterator.value, @"abc2".data);

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc1".data);
	XCTAssertEqualObjects(iterator.value, @"abc1".data);

	[iterator next];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToLast];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc1".data);
	XCTAssertEqualObjects(iterator.value, @"abc1".data);

	[iterator seekToKey:@"abc".data];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToKey:@"abc999".data];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"abc3".data);
	XCTAssertEqualObjects(iterator.value, @"abc3".data);

	[iterator close];
}

- (void)testComparator_StringCompare_Ascending
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
	}];


	NSMutableArray *expected = [NSMutableArray array];
	for (int i = 0; i < 10000; i++) {
		NSString *str = [NSString stringWithFormat:@"A%d", i];
		[expected addObject:str];
		[_rocks setData:str.data forKey:str.data error:nil];
	}

	/* Expected Array: [A0, A1, A10, A100, A1000, A1001, A1019, A102, A1020, ...] */
	[expected sortUsingSelector:@selector(compare:)];

	__block NSUInteger idx = 0;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(NSData *key, BOOL *stop) {
		XCTAssertEqualObjects([[NSString alloc] initWithData:key], expected[idx]);
		idx++;
	}];
}

- (void)testComparator_StringCompare_Descending
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareDescending];
	}];


	NSMutableArray *expected = [NSMutableArray array];
	for (int i = 0; i < 10000; i++) {
		NSString *str = [NSString stringWithFormat:@"A%d", i];
		[expected addObject:str];
		[_rocks setData:str.data forKey:str.data error:nil];
	}

	/* Expected Array: [A9999, A9998 .. A9990, A999, A9989, ...] */
	[expected sortUsingSelector:@selector(compare:)];

	__block NSUInteger idx = 9999;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(NSData * key, BOOL *stop) {
		XCTAssertEqualObjects([[NSString alloc] initWithData:key], expected[idx]);
		idx--;
	}];
}

@end
