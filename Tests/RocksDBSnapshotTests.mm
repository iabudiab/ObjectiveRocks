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

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1") error:nil];
	[_rocks setData:Data(@"Value 2") forKey:Data(@"Key 2") error:nil];
	[_rocks setData:Data(@"Value 3") forKey:Data(@"Key 3") error:nil];

	RocksDBSnapshot *snapshot = [_rocks snapshot];

	[_rocks deleteDataForKey:Data(@"Key 1") error:nil];
	[_rocks setData:Data(@"Value 4") forKey:Data(@"Key 4") error:nil];

	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 1") error:nil], Data(@"Value 1"));
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 2") error:nil], Data(@"Value 2"));
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 3") error:nil], Data(@"Value 3"));
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 4") error:nil], nil);

	[snapshot close];

	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 1") error:nil], nil);
	XCTAssertEqualObjects([snapshot dataForKey:Data(@"Key 4") error:nil], Data(@"Value 4"));
}

- (void)testSnapshot_Iterator
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1") error:nil];
	[_rocks setData:Data(@"Value 2") forKey:Data(@"Key 2") error:nil];
	[_rocks setData:Data(@"Value 3") forKey:Data(@"Key 3") error:nil];

	RocksDBSnapshot *snapshot = [_rocks snapshot];

	[_rocks deleteDataForKey:Data(@"Key 1") error:nil];
	[_rocks setData:Data(@"Value 4") forKey:Data(@"Key 4") error:nil];


	NSMutableArray *actual = [NSMutableArray array];
	RocksDBIterator *iterator = [snapshot iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	NSArray *expected = @[ @"Key 1", @"Key 2", @"Key 3" ];
	XCTAssertEqualObjects(actual, expected);

	[snapshot close];

	[actual removeAllObjects];
	iterator = [snapshot iterator];
	[iterator enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[actual addObject:Str(key)];
	}];

	expected = @[ @"Key 2", @"Key 3", @"Key 4" ];
	XCTAssertEqualObjects(actual, expected);
}

- (void)testSnapshot_SequenceNumber
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1") error:nil];
	RocksDBSnapshot *snapshot1 = [_rocks snapshot];

	[_rocks setData:Data(@"Value 2") forKey:Data(@"Key 2") error:nil];
	RocksDBSnapshot *snapshot2 = [_rocks snapshot];

	[_rocks setData:Data(@"Value 3") forKey:Data(@"Key 3") error:nil];
	RocksDBSnapshot *snapshot3 = [_rocks snapshot];

	XCTAssertEqual(snapshot1.sequenceNumber, 1);
	XCTAssertEqual(snapshot2.sequenceNumber, 2);
	XCTAssertEqual(snapshot3.sequenceNumber, 3);

	[snapshot1 close];
	[snapshot2 close];
	[snapshot3 close];
}

@end
