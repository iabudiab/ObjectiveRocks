//
//  RocksDBMergeOperatorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 08/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBMergeOperatorTests : RocksDBTests

@end

@implementation RocksDBMergeOperatorTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] resourcePath];
	_path = [_path stringByAppendingPathComponent:@"ObjectiveRocks"];
	[self cleanupDB];
}

- (void)tearDown
{
	[_rocks close];
	[self cleanupDB];
	[super tearDown];
}

- (void)cleanupDB
{
	[[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

- (void)testAssociativeMergeOperator
{
	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
																  andBlock:^id (id key, id existingValue, id value) {
																	  uint64_t prev = 0;
																	  if (existingValue != nil) {
																		  [existingValue getBytes:&prev length:sizeof(uint64_t)];
																	  }

																	  uint64_t plus;
																	  [value getBytes:&plus length:sizeof(uint64_t)];

																	  uint64_t result = prev + plus;
																	  return [NSData dataWithBytes:&result length:sizeof(uint64_t)];
																  }];

	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;
	}];

	uint64_t value = 1;
	[_rocks mergeData:NumData(value) forKey:Data(@"Key 1")];

	value = 5;
	[_rocks mergeData:NumData(value) forKey:Data(@"Key 1")];

	uint64_t res;
	Val([_rocks dataForKey:Data(@"Key 1")], res);

	XCTAssertTrue(res == 6);
}

- (void)testAssociativeMergeOperator_NumberAdd_Encoded
{
	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
																  andBlock:^id (id key, NSNumber *existingValue, NSNumber *value) {
																	  NSNumber *result = @(existingValue.floatValue + value.floatValue);
																	  return result;
																  }];

	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;

		options.keyEncoder = ^ NSData * (id key) {
			return [key dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.keyDecoder = ^ NSString * (NSData *data) {
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
		options.valueEncoder = ^ NSData * (id key, id value) {
			float val = [value floatValue];
			NSData *data = [NSData dataWithBytes:&val length:sizeof(val)];
			return data;
		};
		options.valueDecoder = ^ NSNumber * (id key, NSData * data) {
			if (data == nil) return nil;

			float value;
			[data getBytes:&value length:sizeof(value)];
			return @(value);
		};
	}];

	[_rocks mergeObject:@(100.541) forKey:@"Key 1"];

	[_rocks mergeObject:@(200.125) forKey:@"Key 1"];


	XCTAssertEqualWithAccuracy([[_rocks objectForKey:@"Key 1"] floatValue], 300.666, 0.0001);
}

- (void)testAssociativeMergeOperator_DictionaryPut_Encoded
{
	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
																  andBlock:^id (id key, NSMutableDictionary *existingValue, id value) {
																	  NSMutableDictionary *result = [NSMutableDictionary dictionary];
																	  if (existingValue != nil) {
																		  result = existingValue;
																	  }
																	  [result addEntriesFromDictionary:value];
																	  return result;
																  }];

	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;

		options.keyEncoder = ^ NSData * (id key) {
			return [key dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.keyDecoder = ^ NSString * (NSData *data) {
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
		options.valueEncoder = ^ NSData * (id key, id value) {
			NSData *data = [NSJSONSerialization dataWithJSONObject:value
														   options:0
															 error:nil];
			return data;
		};
		options.valueDecoder = ^ NSDictionary * (id key, NSData * data) {
			NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
																		options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers
																		  error:nil];
			return dict;
		};
	}];

	[_rocks setObject:@{@"Key 1": @"Value 1"} forKey:@"Dict Key"];
	
	[_rocks mergeObject:@{@"Key 1": @"Value 1 New"} forKey:@"Dict Key"];

	[_rocks mergeObject:@{@"Key 2": @"Value 2"} forKey:@"Dict Key"];

	[_rocks mergeObject:@{@"Key 3": @"Value 3"} forKey:@"Dict Key"];

	[_rocks mergeObject:@{@"Key 4": @"Value 4"} forKey:@"Dict Key"];

	[_rocks mergeObject:@{@"Key 5": @"Value 5"} forKey:@"Dict Key"];

	NSDictionary *expected = @{@"Key 1" : @"Value 1 New",
							   @"Key 2" : @"Value 2",
							   @"Key 3" : @"Value 3",
							   @"Key 4" : @"Value 4",
							   @"Key 5" : @"Value 5"};

	XCTAssertEqualObjects([_rocks objectForKey:@"Dict Key"], expected);
}

- (void)testMergeOperator_DictionaryUpdate_Encoded
{
	RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
														 partialMergeBlock:^id(id key, NSString *leftOperand, NSString *rightOperand) {
															 NSString *left = [leftOperand componentsSeparatedByString:@":"][0];
															 NSString *right = [rightOperand componentsSeparatedByString:@":"][0];
															 if ([left isEqualToString:right]) {
																 return rightOperand;
															 }
															 return nil;
														 } fullMergeBlock:^id(id key, NSMutableDictionary *existing, NSArray *operands) {
															 for (NSString *op in operands) {
																 NSArray *comp = [op componentsSeparatedByString:@":"];
																 NSString *action = comp[1];
																 if	([action isEqualToString:@"DELETE"]) {
																	 [existing removeObjectForKey:comp[0]];
																 } else {
																	 existing[comp[0]] = comp[2];
																 }
															 }
															 return existing;
														 }];
	
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = mergeOp;

		options.keyEncoder = ^ NSData * (id key) {
			return [key dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.keyDecoder = ^ NSString * (NSData *data) {
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
		options.valueEncoder = ^ NSData * (id key, id value) {
			NSData *data = [NSJSONSerialization dataWithJSONObject:value
														   options:0
															 error:nil];
			return data;
		};
		options.valueDecoder = ^ NSDictionary * (id key, NSData * data) {
			NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
																		options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers
																		  error:nil];
			return dict;
		};
	}];

	NSDictionary *object = @{@"Key 1" : @"Value 1",
							 @"Key 2" : @"Value 2",
							 @"Key 3" : @"Value 3"};

	[_rocks setObject:object forKey:@"Dict Key"];

	[_rocks mergeOperation:@"Key 1:UPDATE:Value X" forKey:@"Dict Key"];
	[_rocks mergeOperation:@"Key 4:INSERT:Value 4" forKey:@"Dict Key"];
	[_rocks mergeOperation:@"Key 2:DELETE" forKey:@"Dict Key"];
	[_rocks mergeOperation:@"Key 1:UPDATE:Value 1 New" forKey:@"Dict Key"];

	NSDictionary *expected = @{@"Key 1" : @"Value 1 New",
							   @"Key 3" : @"Value 3",
							   @"Key 4" : @"Value 4"};

	XCTAssertEqualObjects([_rocks objectForKey:@"Dict Key"], expected);
}

@end
