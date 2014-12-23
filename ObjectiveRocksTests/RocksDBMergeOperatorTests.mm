//
//  RocksDBMergeOperatorTests.m
//  ObjectiveRocks
//
//  Created by Iska on 08/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveRocks.h"

#define NumData(x) [NSData dataWithBytes:&x length:sizeof(x)]
#define StrData(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Val(data, x) [data getBytes:&x length:sizeof(x)];

@interface RocksDBMergeOperatorTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
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
	RocksDBMergeOperator *addOperator = [RocksDBMergeOperator operatorWithName:@"operator"
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
		options.mergeOperator = addOperator;
	}];

	uint64_t value = 1;
	[_rocks mergeData:NumData(value) forKey:StrData(@"Key 1")];

	value = 5;
	[_rocks mergeData:NumData(value) forKey:StrData(@"Key 1")];

	uint64_t res;
	Val([_rocks dataForKey:StrData(@"Key 1")], res);
	
	XCTAssertTrue(res == 6);
}

- (void)testAssociativeMergeOperator_Encoded
{
	RocksDBMergeOperator *addOperator = [RocksDBMergeOperator operatorWithName:@"operator"
																	  andBlock:^id (id key, NSNumber *existingValue, NSNumber *value) {
																		  NSNumber *result = @(existingValue.floatValue + value.floatValue);
																		  return result;
																	  }];

	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.mergeOperator = addOperator;

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

@end
