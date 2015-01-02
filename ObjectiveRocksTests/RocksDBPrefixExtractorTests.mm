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
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.prefixExtractor = [RocksDBPrefixExtractor prefixExtractorWithType:RocksDBPrefixFixedLength length:3];

		options.keyType = RocksDBTypeNSString;
		options.valueType = RocksDBTypeNSString;
	}];

	[_rocks setObject:@"x" forKey:@"100A"];
	[_rocks setObject:@"x" forKey:@"100B"];

	[_rocks setObject:@"x" forKey:@"101A"];
	[_rocks setObject:@"x" forKey:@"101B"];

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

	[iterator seekToKey:@"100XYZ"];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"100A");

	[iterator next];

	XCTAssertTrue(iterator.isValid);
	XCTAssertEqualObjects(iterator.key, @"100B");
}

@end
