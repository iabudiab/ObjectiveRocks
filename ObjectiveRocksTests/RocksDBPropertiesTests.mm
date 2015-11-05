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

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1") error:nil];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2") error:nil];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3") error:nil];

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
