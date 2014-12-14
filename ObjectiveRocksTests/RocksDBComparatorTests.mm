//
//  RocksDBComparatorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 04/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Str(x)	[[NSString alloc] initWithData:x encoding:NSUTF8StringEncoding]

@interface RocksDBComparatorTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBComparatorTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] resourcePath];
	_path = [_path stringByAppendingPathComponent:@"ObjectiveRocks"];
	[self cleanupDB];
}

- (void)tearDown
{
	[_rocks close];
	[self cleanupDB];
	[super tearDown];
}

- (void)cleanupDB
{
	[[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

- (void)testDB_Comparator_StringCompare
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithName:@"comparator" andBlock:^int (id key1, id key2) {
			return [Str(key1) compare:Str(key2)];
		}];
	}];

	/* Expected Array: [A0, A1, A11, A12 ... A2, A21 ...] */
	NSMutableArray *expected = [NSMutableArray array];
	for (int i = 0; i < 26; i++) {
		NSString *str = [NSString stringWithFormat:@"A%d", i];
		[expected addObject:str];
		[_rocks setData:Data(str) forKey:Data(str)];
	}
	[expected sortUsingSelector:@selector(compare:)];

	__block NSUInteger idx = 0;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertEqualObjects(Str(key), expected[idx]);
		idx++;
	}];
}

- (void)testDB_Comparator_StringLengthCompare_Asc
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithName:@"comparator" andBlock:^int (id key1, id key2) {
			if (Str(key1).length > Str(key2).length) return 1;
			if (Str(key1).length < Str(key2).length) return -1;
			return 0;
		}];
	}];

	/* Expected Array: [A, BB, CCC, ... , Y{25}, Z{26}] */
	NSMutableArray *expected = [NSMutableArray array];
	for (unichar i = 65; i <= 90; i++) {
		NSString *str = [NSString stringWithCharacters:&i length:1];
		str = [str stringByPaddingToLength:(i-64) withString:str startingAtIndex:0];
		[expected addObject:str];
		[_rocks setData:Data(str) forKey:Data(str)];
	}

	__block NSUInteger idx = 0;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertEqualObjects(Str(key), expected[idx]);
		idx++;
	}];
}

- (void)testDB_Comparator_StringLengthCompare_Desc
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithName:@"comparator" andBlock:^int (id key1, id key2) {
			if (Str(key1).length > Str(key2).length) return -1;
			if (Str(key1).length < Str(key2).length) return 1;
			return 0;
		}];
	}];

	/* Expected Array: [Z{26}, Y{25}, ..., CCC, BB, A] */
	NSMutableArray *expected = [NSMutableArray array];
	for (unichar i = 90; i >= 65; i--) {
		NSString *str = [NSString stringWithCharacters:&i length:1];
		str = [str stringByPaddingToLength:(i-64) withString:str startingAtIndex:0];
		[expected addObject:str];
		[_rocks setData:Data(str) forKey:Data(str)];
	}

	__block NSUInteger idx = 0;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertEqualObjects(Str(key), expected[idx]);
		idx++;
	}];
}

- (void)testDB_Comparator_StringLengthCompare_Desc_Encoded
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithName:@"comparator" andBlock:^int (NSString *key1, NSString *key2) {
			if (key1.length > key2.length) return -1;
			if (key1.length < key2.length) return 1;
			return 0;
		}];

		options.keyEncoder = ^ NSData * (id key) {
			return [key dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.keyDecoder = ^ NSString * (NSData *data) {
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
		options.valueEncoder = ^ NSData * (id key, id value) {
			return [value dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.valueDecoder = ^ NSString * (id key, NSData * data) {
			if (data == nil) return nil;
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
	}];

	/* Expected Array: [Z{26}, Y{25}, ..., CCC, BB, A] */
	NSMutableArray *expected = [NSMutableArray array];
	for (unichar i = 90; i >= 65; i--) {
		NSString *str = [NSString stringWithCharacters:&i length:1];
		str = [str stringByPaddingToLength:(i-64) withString:str startingAtIndex:0];
		[expected addObject:str];
		[_rocks setObject:str forKey:str];
	}

	__block NSUInteger idx = 0;
	RocksDBIterator *iterator = [_rocks iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		XCTAssertEqualObjects(key, expected[idx]);
		idx++;
	}];
}

@end
