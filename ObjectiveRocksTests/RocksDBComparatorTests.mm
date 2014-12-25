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
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseAscending];
	}];

	[_rocks setData:Data(@"abc1") forKey:Data(@"abc1")];
	[_rocks setData:Data(@"abc2") forKey:Data(@"abc2")];
	[_rocks setData:Data(@"abc3") forKey:Data(@"abc3")];

	RocksDBIterator *iterator = [_rocks iterator];

	[iterator seekToFirst];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc1"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc1"));

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc2"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc2"));

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc3"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc3"));

	[iterator next];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToLast];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc3"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc3"));

	[iterator seekToKey:Data(@"abc")];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc1"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc1"));

	[iterator close];
}

- (void)testComparator_Native_Bytewise_Descending
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseDescending];
	}];

	[_rocks setData:Data(@"abc1") forKey:Data(@"abc1")];
	[_rocks setData:Data(@"abc2") forKey:Data(@"abc2")];
	[_rocks setData:Data(@"abc3") forKey:Data(@"abc3")];

	RocksDBIterator *iterator = [_rocks iterator];

	[iterator seekToFirst];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc3"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc3"));

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc2"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc2"));

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc1"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc1"));

	[iterator next];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToLast];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc1"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc1"));

	[iterator seekToKey:Data(@"abc")];

	XCTAssertFalse(iterator.isValid);

	[iterator seekToKey:Data(@"abc999")];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, Data(@"abc3"));
	XCTAssertEqualObjects(iterator.value, Data(@"abc3"));

	[iterator close];
}

- (void)testComparator_StringCompare_Ascending
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
		options.keyType = RocksDBTypeNSString;
	}];


	NSMutableArray *expected = [NSMutableArray array];
	for (int i = 0; i < 10000; i++) {
		NSString *str = [NSString stringWithFormat:@"A%d", i];
		[expected addObject:str];
		[_rocks setData:Data(str) forKey:Data(str)];
	}

	/* Expected Array: [A0, A1, A10, A100, A1000, A1001, A1019, A102, A1020, ...] */
	[expected sortUsingSelector:@selector(compare:)];

	__block NSUInteger idx = 0;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertEqualObjects(key, expected[idx]);
		idx++;
	}];
}

- (void)testComparator_StringCompare_Descending
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareDescending];
		options.keyType = RocksDBTypeNSString;
	}];


	NSMutableArray *expected = [NSMutableArray array];
	for (int i = 0; i < 10000; i++) {
		NSString *str = [NSString stringWithFormat:@"A%d", i];
		[expected addObject:str];
		[_rocks setData:Data(str) forKey:Data(str)];
	}

	/* Expected Array: [A9999, A9998 .. A9990, A999, A9989, ...] */
	[expected sortUsingSelector:@selector(compare:)];

	__block NSUInteger idx = 9999;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertEqualObjects(key, expected[idx]);
		idx--;
	}];
}

- (void)testComparator_Number_Ascending
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorNumberAscending];

		options.keyEncoder = ^ NSData * (id key) {
			u_int32_t r = [key unsignedIntValue];
			return NumData(r);
		};
		options.keyDecoder = ^ id (NSData *data) {
			if (data == nil) return nil;
			u_int32_t r;
			Val(data, r);
			return @(r);
		};
	}];

	for (int i = 0; i < 10000; i++) {
		u_int32_t r = arc4random_uniform(UINT32_MAX);
		if ([_rocks objectForKey:@(r)] != nil) {
			i--;
		} else {
			[_rocks setObject:Data(@"value") forKey:@(r)];
		}
	}

	__block NSUInteger count = 0;
	__block NSNumber *lastKey = [NSNumber numberWithUnsignedInt:0];

	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertGreaterThan(key, lastKey);
		lastKey = key;
		count++;
	}];

	XCTAssertEqual(count, 10000);
}

- (void)testComparator_Number_Descending
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorNumberDescending];

		options.keyEncoder = ^ NSData * (id key) {
			u_int32_t r = [key unsignedIntValue];
			return NumData(r);
		};
		options.keyDecoder = ^ id (NSData *data) {
			if (data == nil) return nil;
			u_int32_t r;
			Val(data, r);
			return @(r);
		};
	}];

	for (int i = 0; i < 10000; i++) {
		u_int32_t r = arc4random_uniform(UINT32_MAX);
		if ([_rocks objectForKey:@(r)] != nil) {
			i--;
		} else {
			[_rocks setObject:Data(@"value") forKey:@(r)];
		}
	}

	__block NSUInteger count = 0;
	__block NSNumber *lastKey = [NSNumber numberWithUnsignedInt:UINT32_MAX];

	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertLessThan(key, lastKey);
		lastKey = key;
		count++;
	}];

	XCTAssertEqual(count, 10000);
}

@end
