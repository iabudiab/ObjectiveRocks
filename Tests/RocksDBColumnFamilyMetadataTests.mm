//
//  RocksDBColumnFamilyMetadataTests.m
//  ObjectiveRocks
//
//  Created by Iska on 10/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBColumnFamilyMetadataTests : RocksDBTests

@end

@implementation RocksDBColumnFamilyMetadataTests

- (void)testColumnFamilies_Metadata
{
	RocksDBColumnFamilyDescriptor *descriptor = [RocksDBColumnFamilyDescriptor new];
	[descriptor addDefaultColumnFamilyWithOptions:nil];
	[descriptor addColumnFamilyWithName:@"new_cf" andOptions:nil];

	_rocks = [RocksDB databaseAtPath:_path columnFamilies:descriptor andDatabaseOptions:^(RocksDBDatabaseOptions *options) {
		options.createIfMissing = YES;
		options.createMissingColumnFamilies = YES;
	}];

	RocksDBColumnFamily *defaultColumnFamily = _rocks.columnFamilies[0];
	RocksDBColumnFamily *newColumnFamily = _rocks.columnFamilies[1];

	[defaultColumnFamily setData:@"df_value1".data forKey:@"df_key1".data error:nil];
	[defaultColumnFamily setData:@"df_value2".data forKey:@"df_key2".data error:nil];

	[newColumnFamily setData:@"cf_value1".data forKey:@"cf_key1".data error:nil];
	[newColumnFamily setData:@"cf_value2".data forKey:@"cf_key2".data error:nil];

	RocksDBColumnFamilyMetaData *defaultMetadata = defaultColumnFamily.columnFamilyMetaData;
	XCTAssertNotNil(defaultMetadata);

	RocksDBColumnFamilyMetaData *newColumnFamilyMetadata = newColumnFamily.columnFamilyMetaData;
	XCTAssertNotNil(newColumnFamilyMetadata);
}

@end
