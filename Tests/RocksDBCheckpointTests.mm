//
//  RocksDBCheckpointTests.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBCheckpointTests : RocksDBTests

@end

@implementation RocksDBCheckpointTests

- (void)testCheckpoint
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];

	RocksDBCheckpoint *checkpoint = [[RocksDBCheckpoint alloc] initWithDatabase:_rocks];

	[checkpoint createCheckpointAtPath:_chekpointPath_1 error:nil];

	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];

	[checkpoint createCheckpointAtPath:_chekpointPath_2 error:nil];

	[_rocks close];

	_rocks = [RocksDB databaseAtPath:_chekpointPath_1 andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	XCTAssertEqualObjects([_rocks dataForKey:@"key 1".data error:nil], @"value 1".data);
	XCTAssertNil([_rocks dataForKey:@"key 2".data error:nil]);

	[_rocks close];

	_rocks = [RocksDB databaseAtPath:_chekpointPath_2 andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	XCTAssertEqualObjects([_rocks dataForKey:@"key 1".data error:nil], @"value 1".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"key 2".data error:nil], @"value 2".data);
}

@end
