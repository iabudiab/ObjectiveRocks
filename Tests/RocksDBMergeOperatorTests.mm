//
//  RocksDBMergeOperatorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 08/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

#pragma mark - Categories

@interface NSNumber (DataConvertible)
@end

@implementation NSNumber (RocksDBDataConvertible)
- (instancetype)initWithData:(NSData *)data
{
	double_t value;
	[data getBytes:&value length:sizeof(value)];
	return [self initWithDouble:value];
}

- (NSData *)data
{
	double_t value = self.doubleValue;
	return [NSData dataWithBytes:&value length:sizeof(value)];
}
@end

@interface NSDictionary (DataConvertible)
@end

@implementation NSDictionary (RocksDBDataConvertible)
- (instancetype)initWithData:(NSData *)data
{
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
	return [self initWithDictionary:dict];
}

- (NSData *)data
{
	return [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}
@end

#pragma mark - Tests

@interface RocksDBMergeOperatorTests : RocksDBTests
@end

@implementation RocksDBMergeOperatorTests

- (void)testAssociativeMergeOperator
{
	id block = ^NSData * (NSData *key, NSData *existingValue, NSData *value) {
		NSNumber *prev = 0;
		if (existingValue != nil) {
			prev = [[NSNumber alloc] initWithData:existingValue];
		}
		NSNumber *plus = [[NSNumber alloc] initWithData:value];
		NSNumber *result = [NSNumber numberWithUnsignedLongLong:
							(prev.unsignedLongLongValue + plus.unsignedLongLongValue)];
		return result.data;
	};

	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
																  andBlock:block];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;
	}];

	[_rocks mergeData:@(1).data forKey:@"Key 1".data error:nil];

	[_rocks mergeData:@(5).data forKey:@"Key 1".data error:nil];

	NSNumber *res = [[NSNumber alloc] initWithData:[_rocks dataForKey:@"Key 1".data error:nil]];
	XCTAssertEqual(res.unsignedLongLongValue, 6);
}

- (void)testAssociativeMergeOperator_NumberAdd
{
	id block = ^NSData *(NSData *key, NSData *existingValue, NSData *value) {
		NSNumber *v1 = [[NSNumber alloc] initWithData:existingValue];
		NSNumber *v2 = [[NSNumber alloc] initWithData:value];

		NSNumber *result = [[NSNumber alloc] initWithFloat:(v1.floatValue + v2.floatValue)];
		return result.data;
	};

	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
																  andBlock:block];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;
	}];

	[_rocks mergeData:@(100.541).data forKey:@"Key 1".data error:nil];

	[_rocks mergeData:@(200.125).data forKey:@"Key 1".data error:nil];

	NSNumber *number = [[NSNumber alloc] initWithData:[_rocks dataForKey:@"Key 1".data error:nil]];
	XCTAssertEqualWithAccuracy(number.floatValue, 300.666, 0.0001);
}

- (void)testAssociativeMergeOperator_DictionaryPut
{
	id block = ^NSData *(NSData *key, NSData *existingValue, NSData *value) {
		if (existingValue == nil) {
			return value;
		}
		NSMutableDictionary *existing = [[NSMutableDictionary alloc] initWithData:existingValue];
		NSDictionary *dict = [[NSMutableDictionary alloc] initWithData:value];
		[existing addEntriesFromDictionary:dict];
		return existing.data;
	};

	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
																  andBlock:block];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;
	}];

	[_rocks setData:@{@"Key 1": @"Value 1"}.data forKey:@"Dict Key".data error:nil];
	
	[_rocks mergeData:@{@"Key 1": @"Value 1 New"}.data forKey:@"Dict Key".data error:nil];

	[_rocks mergeData:@{@"Key 2": @"Value 2"}.data forKey:@"Dict Key".data error:nil];

	[_rocks mergeData:@{@"Key 3": @"Value 3"}.data forKey:@"Dict Key".data error:nil];

	[_rocks mergeData:@{@"Key 4": @"Value 4"}.data forKey:@"Dict Key".data error:nil];

	[_rocks mergeData:@{@"Key 5": @"Value 5"}.data forKey:@"Dict Key".data error:nil];

	NSDictionary *expected = @{@"Key 1" : @"Value 1 New",
							   @"Key 2" : @"Value 2",
							   @"Key 3" : @"Value 3",
							   @"Key 4" : @"Value 4",
							   @"Key 5" : @"Value 5"};

	NSDictionary *actual = [[NSDictionary alloc] initWithData:[_rocks dataForKey:@"Dict Key".data error:nil]];
	XCTAssertEqualObjects(actual, expected);
}

- (void)testMergeOperator_DictionaryUpdate
{
	id partialMerge = ^NSData *(NSData * key, NSData *leftOperand, NSData *rightOperand) {
		NSString *left = [[[NSString alloc] initWithData:leftOperand] componentsSeparatedByString:@":"][0];
		NSString *right = [[[NSString alloc] initWithData:rightOperand] componentsSeparatedByString:@":"][0];
		if ([left isEqualToString:right]) {
			return rightOperand;
		}
		return nil;
	};

	id fullMerge = ^NSData *(NSData * key, NSData * _Nullable existingValue, NSArray<NSData *> *operandList) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithData:existingValue];

		for (NSData *op in operandList) {
			NSArray *comp = [[[NSString alloc] initWithData:op] componentsSeparatedByString:@":"];
			NSString *action = comp[1];
			if	([action isEqualToString:@"DELETE"]) {
				[dict removeObjectForKey:comp[0]];
			} else {
				dict[comp[0]] = comp[2];
			}
		}
		return dict.data;
	};

	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
														 partialMergeBlock:partialMerge
															fullMergeBlock:fullMerge];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;
	}];

	NSDictionary *object = @{@"Key 1" : @"Value 1",
							 @"Key 2" : @"Value 2",
							 @"Key 3" : @"Value 3"};

	[_rocks setData:object.data forKey:@"Dict Key".data error:nil];

	[_rocks mergeData:@"Key 1:UPDATE:Value X".data forKey:@"Dict Key".data error:nil];
	[_rocks mergeData:@"Key 4:INSERT:Value 4".data forKey:@"Dict Key".data error:nil];
	[_rocks mergeData:@"Key 2:DELETE".data forKey:@"Dict Key".data error:nil];
	[_rocks mergeData:@"Key 1:UPDATE:Value 1 New".data forKey:@"Dict Key".data error:nil];

	NSDictionary *expected = @{@"Key 1" : @"Value 1 New",
							   @"Key 3" : @"Value 3",
							   @"Key 4" : @"Value 4"};

	NSDictionary *actual = [[NSDictionary alloc] initWithData:[_rocks dataForKey:@"Dict Key".data error:nil]];

	XCTAssertEqualObjects(actual, expected);
}

@end
