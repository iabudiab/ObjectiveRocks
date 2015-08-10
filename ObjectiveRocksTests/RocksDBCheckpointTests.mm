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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];

	RocksDBCheckpoint *checkpoint = [[RocksDBCheckpoint alloc] initWithDatabase:_rocks];

	[checkpoint createCheckpointAtPath:_chekpointPath_1 error:nil];

	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];

	[checkpoint createCheckpointAtPath:_chekpointPath_2 error:nil];

	[_rocks close];

	_rocks = [RocksDB databaseAtPath:_chekpointPath_1 andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertNil([_rocks dataForKey:Data(@"key 2")]);

	[_rocks close];

	_rocks = [RocksDB databaseAtPath:_chekpointPath_2 andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"key 2")], Data(@"value 2"));
}

@end
