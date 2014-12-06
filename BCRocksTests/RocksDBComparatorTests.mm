//
//  RocksDBComparatorTests.m
//  BCRocks
//
//  Created by Iska on 04/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCRocks.h"

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

- (void)testDB_Comparator_StringCompare
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = ^ int (NSData *data1, NSData *data2) {
			return [Str(data1) compare:Str(data2)];
		};
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
		options.comparator = ^ int (NSData *data1, NSData *data2) {
			if (Str(data1).length > Str(data2).length) return 1;
			if (Str(data1).length < Str(data2).length) return -1;
			return 0;
		};
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
		options.comparator = ^ int (NSData *data1, NSData *data2) {
			if (Str(data1).length > Str(data2).length) return -1;
			if (Str(data1).length < Str(data2).length) return 1;
			return 0;
		};
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

@end
