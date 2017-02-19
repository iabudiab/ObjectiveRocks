//
//  RocksDBSnapshotTests.m
//  ObjectiveRocks
//
//  Created by Iska on 06/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBSnapshotTests : RocksDBTests

@end

@implementation RocksDBSnapshotTests

- (void)testSnapshot
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];
	[_rocks setData:@"Value 2".data forKey:@"Key 2".data error:nil];
	[_rocks setData:@"Value 3".data forKey:@"Key 3".data error:nil];

	RocksDBSnapshot *snapshot = [_rocks snapshot];

	[_rocks deleteDataForKey:@"Key 1".data error:nil];
	[_rocks setData:@"Value 4".data forKey:@"Key 4".data error:nil];

	XCTAssertEqualObjects([snapshot dataForKey:@"Key 1".data error:nil], @"Value 1".data);
	XCTAssertEqualObjects([snapshot dataForKey:@"Key 2".data error:nil], @"Value 2".data);
	XCTAssertEqualObjects([snapshot dataForKey:@"Key 3".data error:nil], @"Value 3".data);
	XCTAssertEqualObjects([snapshot dataForKey:@"Key 4".data error:nil], nil);

	[snapshot close];

	XCTAssertEqualObjects([snapshot dataForKey:@"Key 1".data error:nil], nil);
	XCTAssertEqualObjects([snapshot dataForKey:@"Key 4".data error:nil], @"Value 4".data);
}

- (void)testSnapshot_Iterator
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];
	[_rocks setData:@"Value 2".data forKey:@"Key 2".data error:nil];
	[_rocks setData:@"Value 3".data forKey:@"Key 3".data error:nil];

	RocksDBSnapshot *snapshot = [_rocks snapshot];

	[_rocks deleteDataForKey:@"Key 1".data error:nil];
	[_rocks setData:@"Value 4".data forKey:@"Key 4".data error:nil];


	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [snapshot iterator];
	[iterator enumerateKeysUsingBlock:^(NSData *key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	NSArray *expected = @[ @"Key 1", @"Key 2", @"Key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[snapshot close];

	[actual removeAllObjects];
	iterator = [snapshot iterator];
	[iterator enumerateKeysUsingBlock:^(NSData *key, BOOL *stop) {
		[actual addObject:[[NSString alloc] initWithData:key]];
	}];

	expected = @[ @"Key 2", @"Key 3", @"Key 4" ];
	XCTAssertEqualObjects(actual, expected);
}

- (void)testSnapshot_SequenceNumber
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];
	RocksDBSnapshot *snapshot1 = [_rocks snapshot];

	[_rocks setData:@"Value 2".data forKey:@"Key 2".data error:nil];
	RocksDBSnapshot *snapshot2 = [_rocks snapshot];

	[_rocks setData:@"Value 3".data forKey:@"Key 3".data error:nil];
	RocksDBSnapshot *snapshot3 = [_rocks snapshot];

	XCTAssertEqual(snapshot1.sequenceNumber, 1);
	XCTAssertEqual(snapshot2.sequenceNumber, 2);
	XCTAssertEqual(snapshot3.sequenceNumber, 3);

	[snapshot1 close];
	[snapshot2 close];
	[snapshot3 close];
}

@end
