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
		[batch setData:Data(@"Value 1") forKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Perform_DeleteOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Perform_ClearOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch deleteDataForKey:Data(@"Key 1")];
		[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
		[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
		[batch clear];
		[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];
	}];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], Data(@"Value 4"));
}

- (void)testWriteBatch_Apply
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch setData:Data(@"Value 1") forKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Apply_DeleteOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], Data(@"Value 3"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], nil);
}

- (void)testWriteBatch_Apply_MergeOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = [RocksDBMergeOperator operatorWithName:@"merge" andBlock:^id(id key, id existingValue, id value) {
			NSMutableString *result = [NSMutableString string];
 			if (existingValue != nil) {
				[result setString:Str(existingValue)];
			}
			[result appendString:@","];
			[result appendString:Str(value)];
			return Data(result);
		}];
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	[batch mergeData:Data(@"Value 2 New") forKey:Data(@"Key 2")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], Data(@"Value 2,Value 2 New"));
}

- (void)testWriteBatch_Apply_ClearOps
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:Data(@"Key 1")];
	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];
	[batch clear];
	[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];

	[_rocks applyWriteBatch:batch withWriteOptions:nil];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 1")], Data(@"Value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 2")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 3")], nil);
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"Key 4")], Data(@"Value 4"));
}

- (void)testWriteBatch_Count
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"Value 1") forKey:Data(@"Key 1")];

	RocksDBWriteBatch *batch = [_rocks writeBatch];

	[batch deleteDataForKey:Data(@"Key 1")];

	XCTAssertEqual(batch.count, 1);

	[batch setData:Data(@"Value 2") forKey:Data(@"Key 2")];
	[batch setData:Data(@"Value 3") forKey:Data(@"Key 3")];

	XCTAssertEqual(batch.count, 3);

	[batch clear];

	XCTAssertEqual(batch.count, 0);

	[batch setData:Data(@"Value 4") forKey:Data(@"Key 4")];
	[batch setData:Data(@"Value 5") forKey:Data(@"Key 4")];

	XCTAssertEqual(batch.count, 2);

	[batch deleteDataForKey:Data(@"Key 4")];

	XCTAssertEqual(batch.count, 3);
}

- (void)testWriteBatch_Encoded
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.keyType = RocksDBTypeNSString;
		options.valueType = RocksDBTypeNSString;
	}];

	[_rocks setObject:@"Value 1" forKey:@"Key 1"];

	[_rocks performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *options) {
		[batch setObject:@"Value 2" forKey:@"Key 2"];
		[batch setObject:@"Value 3" forKey:@"Key 3"];
		[batch deleteObjectForKey:@"Key 1"];
	}];

	XCTAssertEqualObjects([_rocks objectForKey:@"Key 1"], nil);
	XCTAssertEqualObjects([_rocks objectForKey:@"Key 2"], @"Value 2");
	XCTAssertEqualObjects([_rocks objectForKey:@"Key 3"], @"Value 3");
}

@end
