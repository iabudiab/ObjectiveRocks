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

		options.keyType = RocksDBTypeNSString;
		options.valueType = RocksDBTypeNSString;
	}];

	[_rocks setObject:@"x" forKey:@"100A" error:nil];
	[_rocks setObject:@"x" forKey:@"100B" error:nil];

	[_rocks setObject:@"x" forKey:@"101A" error:nil];
	[_rocks setObject:@"x" forKey:@"101B" error:nil];

	RocksDBIterator *iterator = [_rocks iterator];


	NSMutableArray *keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"100" usingBlock:^(id key, BOOL *stop) {
		[keys addObject:key];
	}];

	XCTAssertEqual(keys.count, 2);

	NSArray *expected = @[@"100A", @"100B"];
	XCTAssertEqualObjects(keys, expected);

	keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"101" usingBlock:^(id key, BOOL *stop) {
		[keys addObject:key];
	}];

	XCTAssertEqual(keys.count, 2);

	expected = @[@"101A", @"101B"];
	XCTAssertEqualObjects(keys, expected);

	[iterator seekToKey:@"1000"];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"100A");

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"100B");
}

- (void)testPrefixExtractor_FixedLength_CustomComparator
{
	// 1001 < 9910 < 2011 < 3412 ...
	RocksDBComparator *cmp = [[RocksDBComparator alloc] initWithName:@"cmp" andBlock:^int(id key1, id key2) {
		return [[key1 substringFromIndex:2] compare:[key2 substringFromIndex:2]];
	}];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = cmp;
		options.prefixExtractor = [RocksDBPrefixExtractor prefixExtractorWithType:RocksDBPrefixFixedLength length:2];

		options.memtablePrefixBloomBits = 100000000;
		options.memtablePrefixBloomProbes = 6;

		options.tableFacotry = [RocksDBTableFactory blockBasedTableFactoryWithOptions:^(RocksDBBlockBasedTableOptions *options) {
			options.filterPolicy = [RocksDBFilterPolicy bloomFilterPolicyWithBitsPerKey:10 useBlockBasedBuilder:YES];
		}];

		options.keyType = RocksDBTypeNSString;
		options.valueType = RocksDBTypeNSString;
	}];

	[_rocks setObject:@"x" forKey:@"1010" error:nil];
	[_rocks setObject:@"x" forKey:@"4211" error:nil];
	[_rocks setObject:@"x" forKey:@"1012" error:nil];
	[_rocks setObject:@"x" forKey:@"5313" error:nil];
	[_rocks setObject:@"x" forKey:@"1020" error:nil];
	[_rocks setObject:@"x" forKey:@"4221" error:nil];
	[_rocks setObject:@"x" forKey:@"1022" error:nil];
	[_rocks setObject:@"x" forKey:@"5323" error:nil];

	RocksDBIterator *iterator = [_rocks iterator];

	NSMutableArray *keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"10" usingBlock:^(id key, BOOL *stop) {
		[keys addObject:key];
	}];

	XCTAssertEqual(keys.count, 4);

	NSArray *expected = @[@"1010", @"1012", @"1020", @"1022"];
	XCTAssertEqualObjects(keys, expected);

	keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"42" usingBlock:^(id key, BOOL *stop) {
		[keys addObject:key];
	}];

	XCTAssertEqual(keys.count, 2);

	expected = @[@"4211", @"4221"];
	XCTAssertEqualObjects(keys, expected);

	keys = [NSMutableArray array];
	[iterator enumerateKeysWithPrefix:@"53" usingBlock:^(id key, BOOL *stop) {
		[keys addObject:key];
	}];

	XCTAssertEqual(keys.count, 2);

	expected = @[@"5313", @"5323"];
	XCTAssertEqualObjects(keys, expected);
}

@end
