//
//  RocksDBPropertiesTests.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBPropertiesTests : RocksDBTests

@end

@implementation RocksDBPropertiesTests

- (void)testProperties
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.maxWriteBufferNumber = 10;
		options.minWriteBufferNumberToMerge = 10;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	XCTAssertGreaterThan([_rocks valueForIntProperty:RocksDBIntPropertyNumEntriesActiveMemtable], 0);
	XCTAssertGreaterThan([_rocks valueForIntProperty:RocksDBIntPropertyCurSizeActiveMemTable], 0);
}

- (void)testProperties_ColumnFamily
{
	RocksDBColumnFamilyDescriptor *descriptor = [RocksDBColumnFamilyDescriptor new];
	[descriptor addColumnFamilyWithName:@"default" andOptions:nil];
	[descriptor addColumnFamilyWithName:@"new_cf" andOptions:nil];

	_rocks = [RocksDB databaseAtPath:_path columnFamilies:descriptor andDatabaseOptions:^(RocksDBDatabaseOptions *options) {
		options.createIfMissing = YES;
		options.createMissingColumnFamilies = YES;
	}];

	XCTAssertGreaterThanOrEqual([_rocks.columnFamilies[0] valueForIntProperty:RocksDBIntPropertyEstimatedNumKeys], 0);
	XCTAssertNotNil([(RocksDB *)_rocks.columnFamilies[0] valueForProperty:RocksDBPropertyStats]);
	XCTAssertNotNil([(RocksDB *)_rocks.columnFamilies[0] valueForProperty:RocksDBPropertySsTables]);

	XCTAssertGreaterThanOrEqual([_rocks.columnFamilies[1] valueForIntProperty:RocksDBIntPropertyEstimatedNumKeys], 0);
	XCTAssertNotNil([(RocksDB *)_rocks.columnFamilies[1] valueForProperty:RocksDBPropertyStats]);
	XCTAssertNotNil([(RocksDB *)_rocks.columnFamilies[1] valueForProperty:RocksDBPropertySsTables]);
}

@end
