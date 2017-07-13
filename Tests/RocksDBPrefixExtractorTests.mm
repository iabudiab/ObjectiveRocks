//
//  RocksDBPrefixExtractorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

#import "ObjectiveRocks.h"

@interface RocksDBPrefixExtractorTests : RocksDBTests

@end

@implementation RocksDBPrefixExtractorTests

- (void)testPrefixExtractor_FixedLength
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.prefixExtractor = [RocksDBPrefixExtractor prefixExtractorWithType:RocksDBPrefixFixedLength length:3];
	}];

	[_rocks setData:@"x".data forKey:@"100A".data error:nil];
	[_rocks setData:@"x".data forKey:@"100B".data error:nil];

	[_rocks setData:@"x".data forKey:@"101A".data error:nil];
	[_rocks setData:@"x".data forKey:@"101B".data error:nil];

	RocksDBIterator *iterator = [_rocks iterator];


	NSMutableArray *keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"100".data usingBlock:^(NSData *key, BOOL *stop) {
		[keys addObject:[[NSString alloc] initWithData:key]];
	}];

	XCTAssertEqual(keys.count, 2);

	NSArray *expected = @[@"100A", @"100B"];
	XCTAssertEqualObjects(keys, expected);

	keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"101".data usingBlock:^(NSData *key, BOOL *stop) {
		[keys addObject:[[NSString alloc] initWithData:key]];
	}];

	XCTAssertEqual(keys.count, 2);

	expected = @[@"101A", @"101B"];
	XCTAssertEqualObjects(keys, expected);

	[iterator seekToKey:@"1000".data];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"100A".data);

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"100B".data);
}

- (void)testPrefixExtractor_FixedLength_CustomComparator
{
	// 1001 < 9910 < 2011 < 3412 ...
	RocksDBComparator *cmp = [[RocksDBComparator alloc] initWithName:@"cmp" andBlock:^int(NSData *key1, NSData *key2) {
		NSString *str1 = [[NSString alloc] initWithData:key1];
		NSString *str2 = [[NSString alloc] initWithData:key2];
		return [[str1 substringFromIndex:2] compare:[str2 substringFromIndex:2]];
	}];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = cmp;
		options.prefixExtractor = [RocksDBPrefixExtractor prefixExtractorWithType:RocksDBPrefixFixedLength length:2];

		options.tableFacotry = [RocksDBTableFactory blockBasedTableFactoryWithOptions:^(RocksDBBlockBasedTableOptions *options) {
			options.filterPolicy = [RocksDBFilterPolicy bloomFilterPolicyWithBitsPerKey:10 useBlockBasedBuilder:YES];
		}];
	}];

	[_rocks setData:@"x".data forKey:@"1010".data error:nil];
	[_rocks setData:@"x".data forKey:@"4211".data error:nil];
	[_rocks setData:@"x".data forKey:@"1012".data error:nil];
	[_rocks setData:@"x".data forKey:@"5313".data error:nil];
	[_rocks setData:@"x".data forKey:@"1020".data error:nil];
	[_rocks setData:@"x".data forKey:@"4221".data error:nil];
	[_rocks setData:@"x".data forKey:@"1022".data error:nil];
	[_rocks setData:@"x".data forKey:@"5323".data error:nil];

	RocksDBIterator *iterator = [_rocks iterator];

	NSMutableArray *keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"10".data usingBlock:^(NSData *key, BOOL *stop) {
		[keys addObject:[[NSString alloc] initWithData:key]];
	}];

	XCTAssertEqual(keys.count, 4);

	NSArray *expected = @[@"1010", @"1012", @"1020", @"1022"];
	XCTAssertEqualObjects(keys, expected);

	keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"42".data usingBlock:^(NSData *key, BOOL *stop) {
		[keys addObject:[[NSString alloc] initWithData:key]];
	}];

	XCTAssertEqual(keys.count, 2);

	expected = @[@"4211", @"4221"];
	XCTAssertEqualObjects(keys, expected);

	keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"53".data usingBlock:^(NSData *key, BOOL *stop) {
		[keys addObject:[[NSString alloc] initWithData:key]];
	}];

	XCTAssertEqual(keys.count, 2);

	expected = @[@"5313", @"5323"];
	XCTAssertEqualObjects(keys, expected);
}

@end
