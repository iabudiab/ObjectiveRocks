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

	[defaultColumnFamily setData:Data(@"df_value1") forKey:Data(@"df_key1") error:nil];
	[defaultColumnFamily setData:Data(@"df_value2") forKey:Data(@"df_key2") error:nil];

	[newColumnFamily setData:Data(@"cf_value1") forKey:Data(@"cf_key1") error:nil];
	[newColumnFamily setData:Data(@"cf_value2") forKey:Data(@"cf_key2") error:nil];

	RocksDBColumnFamilyMetaData *defaultMetadata = defaultColumnFamily.columnFamilyMetaData;
	XCTAssertNotNil(defaultMetadata);

	RocksDBColumnFamilyMetaData *newColumnFamilyMetadata = newColumnFamily.columnFamilyMetaData;
	XCTAssertNotNil(newColumnFamilyMetadata);
}

@end
