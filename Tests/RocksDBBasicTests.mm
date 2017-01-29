//
//  RocksDBTests.m
//  ObjectiveRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBBasicTests : RocksDBTests

@end

@implementation RocksDBBasicTests

- (void)testDB_Open_ErrorIfExists
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
	[_rocks close];

	RocksDB *db = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.errorIfExists = YES;
	}];

	XCTAssertNil(db);
}

- (void)testDB_CRUD
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
	[_rocks setDefaultReadOptions:^(RocksDBReadOptions *readOptions) {
		readOptions.fillCache = YES;
		readOptions.verifyChecksums = YES;
	} andWriteOptions:^(RocksDBWriteOptions *writeOptions) {
		writeOptions.syncWrites = YES;
	}];


	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"key 1".data error:nil], @"value 1".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"key 2".data error:nil], @"value 2".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"key 3".data error:nil], @"value 3".data);

	[_rocks deleteDataForKey:@"key 2".data error:nil];
	XCTAssertNil([_rocks dataForKey:@"key 2".data error:nil]);

	NSError *error = nil;
	BOOL ok = [_rocks deleteDataForKey:@"key 2".data error:&error];
	XCTAssertTrue(ok);
	XCTAssertNil(error);
}

@end
