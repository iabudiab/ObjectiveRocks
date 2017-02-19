//
//  RocksDBWriteBatchTests.m
//  ObjectiveRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBWriteBatchTests : RocksDBTests

@end

@implementation RocksDBWriteBatchTests

- (void)testWriteBatch_Perform
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch setData:@"Value 1".data forKey:@"Key 1".data];
		[batch setData:@"Value 2".data forKey:@"Key 2".data];
		[batch setData:@"Value 3".data forKey:@"Key 3".data];
	} error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 1".data error:nil], @"Value 1".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], @"Value 2".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 3".data error:nil], @"Value 3".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 4".data error:nil], nil);
}

- (void)testWriteBatch_Perform_DeleteOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:@"Key 1".data];
		[batch setData:@"Value 2".data forKey:@"Key 2".data];
		[batch setData:@"Value 3".data forKey:@"Key 3".data];
	} error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 1".data error:nil], nil);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], @"Value 2".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 3".data error:nil], @"Value 3".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 4".data error:nil], nil);
}

- (void)testWriteBatch_Perform_ClearOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:@"Key 1".data];
		[batch setData:@"Value 2".data forKey:@"Key 2".data];
		[batch setData:@"Value 3".data forKey:@"Key 3".data];
		[batch clear];
		[batch setData:@"Value 4".data forKey:@"Key 4".data];
	} error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 1".data error:nil], @"Value 1".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], nil);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 3".data error:nil], nil);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 4".data error:nil], @"Value 4".data);
}

- (void)testWriteBatch_Apply
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch setData:@"Value 1".data forKey:@"Key 1".data];
	[batch setData:@"Value 2".data forKey:@"Key 2".data];
	[batch setData:@"Value 3".data forKey:@"Key 3".data];

	[_rocks applyWriteBatch:batch writeOptions:nil error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 1".data error:nil], @"Value 1".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], @"Value 2".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 3".data error:nil], @"Value 3".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 4".data error:nil], nil);
}

- (void)testWriteBatch_Apply_DeleteOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:@"Key 1".data];
	[batch setData:@"Value 2".data forKey:@"Key 2".data];
	[batch setData:@"Value 3".data forKey:@"Key 3".data];

	[_rocks applyWriteBatch:batch writeOptions:nil error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 1".data error:nil], nil);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], @"Value 2".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 3".data error:nil], @"Value 3".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 4".data error:nil], nil);
}

- (void)testWriteBatch_Apply_MergeOps
{
	id block = ^NSData *(NSData *key, NSData *existingValue, NSData *value) {
		NSMutableString *result = [NSMutableString string];
		if (existingValue != nil) {
			[result setString:[[NSString alloc] initWithData:existingValue]];
		}
		[result appendString:@","];
		[result appendString:[[NSString alloc] initWithData:value]];
		return result.data;
	};

	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"merge" andBlock:block];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:@"Key 1".data];
	[batch setData:@"Value 2".data forKey:@"Key 2".data];
	[batch setData:@"Value 3".data forKey:@"Key 3".data];
	[batch mergeData:@"Value 2 New".data forKey:@"Key 2".data];

	[_rocks applyWriteBatch:batch writeOptions:nil error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], @"Value 2,Value 2 New".data);
}

- (void)testWriteBatch_Apply_ClearOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:@"Key 1".data];
	[batch setData:@"Value 2".data forKey:@"Key 2".data];
	[batch setData:@"Value 3".data forKey:@"Key 3".data];
	[batch clear];
	[batch setData:@"Value 4".data forKey:@"Key 4".data];

	[_rocks applyWriteBatch:batch writeOptions:nil error:nil];

	XCTAssertEqualObjects([_rocks dataForKey:@"Key 1".data error:nil], @"Value 1".data);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 2".data error:nil], nil);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 3".data error:nil], nil);
	XCTAssertEqualObjects([_rocks dataForKey:@"Key 4".data error:nil], @"Value 4".data);
}

- (void)testWriteBatch_Count
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"Value 1".data forKey:@"Key 1".data error:nil];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:@"Key 1".data];

	XCTAssertEqual(batch.count, 1);

	[batch setData:@"Value 2".data forKey:@"Key 2".data];
	[batch setData:@"Value 3".data forKey:@"Key 3".data];

	XCTAssertEqual(batch.count, 3);

	[batch clear];

	XCTAssertEqual(batch.count, 0);

	[batch setData:@"Value 4".data forKey:@"Key 4".data];
	[batch setData:@"Value 5".data forKey:@"Key 4".data];

	XCTAssertEqual(batch.count, 2);

	[batch deleteDataForKey:@"Key 4".data];

	XCTAssertEqual(batch.count, 3);
}

@end
