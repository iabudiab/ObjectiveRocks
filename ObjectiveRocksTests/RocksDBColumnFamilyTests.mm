//
//  RocksDBColumnFamilyTests.m
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBColumnFamilyTests : RocksDBTests

@end

@implementation RocksDBColumnFamilyTests

- (void)testColumnFamilies_List
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
	[_rocks close];

	NSArray *names = [RocksDB listColumnFamiliesInDatabaseAtPath:_path];

	XCTAssertTrue(names.count == 1);
	XCTAssertEqualObjects(names[0], @"default");
}

- (void)testColumnFamilies_Create
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBColumnFamily *columnFamily = [_rocks createColumnFamilyWithName:@"new_cf" andOptions:nil];

	[columnFamily close];
	[_rocks close];

	NSArray *names = [RocksDB listColumnFamiliesInDatabaseAtPath:_path];

	XCTAssertTrue(names.count == 2);
	XCTAssertEqualObjects(names[0], @"default");
	XCTAssertEqualObjects(names[1], @"new_cf");
}

- (void)testColumnFamilies_Drop
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBColumnFamily *columnFamily = [_rocks createColumnFamilyWithName:@"new_cf" andOptions:nil];

	[columnFamily drop];
	[columnFamily close];
	[_rocks close];

	NSArray *names = [RocksDB listColumnFamiliesInDatabaseAtPath:_path];

	XCTAssertTrue(names.count == 1);
	XCTAssertEqualObjects(names[0], @"default");
}

@end
