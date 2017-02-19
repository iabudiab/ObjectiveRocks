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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
	[_rocks close];

	NSArray *names = [RocksDB listColumnFamiliesInDatabaseAtPath:_path];

	XCTAssertTrue(names.count == 1);
	XCTAssertEqualObjects(names[0], @"default");
}

- (void)testColumnFamilies_Create
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
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

- (void)testColumnFamilies_Open
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
	}];

	RocksDBColumnFamily *columnFamily = [_rocks createColumnFamilyWithName:@"new_cf" andOptions:^(RocksDBColumnFamilyOptions *options) {
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseDescending];
	}];

	[columnFamily close];
	[_rocks close];

	NSArray *names = [RocksDB listColumnFamiliesInDatabaseAtPath:_path];

	XCTAssertTrue(names.count == 2);
	XCTAssertEqualObjects(names[0], @"default");
	XCTAssertEqualObjects(names[1], @"new_cf");

	RocksDBColumnFamilyDescriptor *descriptor = [RocksDBColumnFamilyDescriptor new];
	[descriptor addColumnFamilyWithName:@"default" andOptions:^(RocksDBColumnFamilyOptions *options) {
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
	}];
	[descriptor addColumnFamilyWithName:@"new_cf" andOptions:^(RocksDBColumnFamilyOptions *options) {
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseDescending];
	}];

	_rocks = [RocksDB databaseAtPath:_path columnFamilies:descriptor andDatabaseOptions:^(RocksDBDatabaseOptions *options) {
		options.createIfMissing = YES;
	}];

	XCTAssertNotNil(_rocks);

	XCTAssertTrue(_rocks.columnFamilies.count == 2);

	RocksDBColumnFamily *defaultColumnFamily = _rocks.columnFamilies[0];
	RocksDBColumnFamily *newColumnFamily = _rocks.columnFamilies[1];

	XCTAssertNotNil(defaultColumnFamily);
	XCTAssertNotNil(newColumnFamily);

	[defaultColumnFamily close];
	[newColumnFamily close];
}

- (void)testColumnFamilies_Open_ComparatorMismatch
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
	}];

	RocksDBColumnFamily *columnFamily = [_rocks createColumnFamilyWithName:@"new_cf" andOptions:^(RocksDBColumnFamilyOptions *options) {
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorBytewiseDescending];
	}];

	[columnFamily close];
	[_rocks close];

	NSArray *names = [RocksDB listColumnFamiliesInDatabaseAtPath:_path];

	XCTAssertTrue(names.count == 2);
	XCTAssertEqualObjects(names[0], @"default");
	XCTAssertEqualObjects(names[1], @"new_cf");

	RocksDBColumnFamilyDescriptor *descriptor = [RocksDBColumnFamilyDescriptor new];
	[descriptor addColumnFamilyWithName:@"default" andOptions:^(RocksDBColumnFamilyOptions *options) {
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
	}];
	[descriptor addColumnFamilyWithName:@"new_cf" andOptions:^(RocksDBColumnFamilyOptions *options) {
		options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorStringCompareAscending];
	}];

	_rocks = [RocksDB databaseAtPath:_path columnFamilies:descriptor andDatabaseOptions:^(RocksDBDatabaseOptions *options) {
		options.createIfMissing = YES;
	}];

	XCTAssertNil(_rocks);
}

- (void)testColumnFamilies_CRUD
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"df_value".data forKey:@"df_key1".data error:nil];
	[_rocks setData:@"df_value".data forKey:@"df_key2".data error:nil];

	RocksDBColumnFamily *columnFamily = [_rocks createColumnFamilyWithName:@"new_cf" andOptions:nil];

	[columnFamily setData:@"cf_value".data forKey:@"cf_key1".data error:nil];
	[columnFamily setData:@"cf_value".data forKey:@"cf_key2".data error:nil];

	[columnFamily close];
	[_rocks close];

	RocksDBColumnFamilyDescriptor *descriptor = [RocksDBColumnFamilyDescriptor new];
	[descriptor addDefaultColumnFamilyWithOptions:nil];
	[descriptor addColumnFamilyWithName:@"new_cf" andOptions:nil];

	_rocks = [RocksDB databaseAtPath:_path columnFamilies:descriptor andDatabaseOptions:^(RocksDBDatabaseOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBColumnFamily *defaultColumnFamily = _rocks.columnFamilies[0];
	RocksDBColumnFamily *newColumnFamily = _rocks.columnFamilies[1];

	XCTAssertEqualObjects([_rocks dataForKey:@"df_key1".data error:nil], @"df_value".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"df_key2".data error:nil], @"df_value".data);
	XCTAssertNil([_rocks dataForKey:@"cf_key1".data error:nil]);
	XCTAssertNil([_rocks dataForKey:@"cf_key2".data error:nil]);

	XCTAssertEqualObjects([defaultColumnFamily dataForKey:@"df_key1".data error:nil], @"df_value".data);
	XCTAssertEqualObjects([defaultColumnFamily dataForKey:@"df_key2".data error:nil], @"df_value".data);

	XCTAssertNil([defaultColumnFamily dataForKey:@"cf_key1".data error:nil]);
	XCTAssertNil([defaultColumnFamily dataForKey:@"cf_key2".data error:nil]);

	XCTAssertEqualObjects([newColumnFamily dataForKey:@"cf_key1".data error:nil], @"cf_value".data);
	XCTAssertEqualObjects([newColumnFamily dataForKey:@"cf_key2".data error:nil], @"cf_value".data);

	XCTAssertNil([newColumnFamily dataForKey:@"df_key1".data error:nil]);
	XCTAssertNil([newColumnFamily dataForKey:@"df_key2".data error:nil]);

	[newColumnFamily deleteDataForKey:@"cf_key1".data error:nil];
	XCTAssertNil([newColumnFamily dataForKey:@"cf_key1".data error:nil]);

	[newColumnFamily deleteDataForKey:@"cf_key1".data error:nil];
	XCTAssertNil([newColumnFamily dataForKey:@"cf_key1".data error:nil]);

	[defaultColumnFamily close];
	[newColumnFamily close];
}

- (void)testColumnFamilies_WriteBatch
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

	[newColumnFamily setData:@"xyz_value".data forKey:@"xyz".data error:nil];

	RocksDBWriteBatch *batch = [newColumnFamily writeBatch];

	[batch setData:@"cf_value1".data forKey:@"cf_key1".data];
	[batch setData:@"df_value".data forKey:@"df_key".data inColumnFamily:defaultColumnFamily];
	[batch setData:@"cf_value2".data forKey:@"cf_key2".data];
	[batch deleteDataForKey:@"xyz".data inColumnFamily:defaultColumnFamily];
	[batch deleteDataForKey:@"xyz".data];

	[_rocks applyWriteBatch:batch writeOptions:nil error:nil];

	XCTAssertEqualObjects([defaultColumnFamily dataForKey:@"df_key".data error:nil], @"df_value".data);
	XCTAssertNil([defaultColumnFamily dataForKey:@"df_key1".data error:nil]);
	XCTAssertNil([defaultColumnFamily dataForKey:@"df_key2".data error:nil]);

	XCTAssertEqualObjects([newColumnFamily dataForKey:@"cf_key1".data error:nil], @"cf_value1".data);
	XCTAssertEqualObjects([newColumnFamily dataForKey:@"cf_key2".data error:nil], @"cf_value2".data);
	XCTAssertNil([newColumnFamily dataForKey:@"df_key".data error:nil]);

	XCTAssertNil([defaultColumnFamily dataForKey:@"xyz".data error:nil]);
	XCTAssertNil([newColumnFamily dataForKey:@"xyz".data error:nil]);

	[defaultColumnFamily close];
	[newColumnFamily close];
}

- (void)testColumnFamilies_Iterator
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

	RocksDBIterator *dfIterator = [defaultColumnFamily iterator];

	NSMutableArray *actual = [NSMutableArray array];
	for ([dfIterator seekToFirst]; [dfIterator isValid]; [dfIterator next]) {
		[actual addObject:[[NSString alloc] initWithData:dfIterator.key]];
		[actual addObject:[[NSString alloc] initWithData:dfIterator.value]];
	}

	NSArray *expected = @[ @"df_key1", @"df_value1", @"df_key2", @"df_value2" ];
	XCTAssertEqualObjects(actual, expected);

	[dfIterator close];

	RocksDBIterator *cfIterator = [newColumnFamily iterator];

	actual = [NSMutableArray array];
	for ([cfIterator seekToFirst]; [cfIterator isValid]; [cfIterator next]) {
		[actual addObject:[[NSString alloc] initWithData:cfIterator.key]];
		[actual addObject:[[NSString alloc] initWithData:cfIterator.value]];
	}

	expected = @[ @"cf_key1", @"cf_value1", @"cf_key2", @"cf_value2" ];
	XCTAssertEqualObjects(actual, expected);

	[cfIterator close];

	[defaultColumnFamily close];
	[newColumnFamily close];
}

@end
