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

- (void)testX
{
	RocksDBMergeOperator *addOperator = [RocksDBMergeOperator operatorWithName:@"operator"
																	  andBlock:^NSData *(NSData *key, NSData *existingValue, NSData *value) {
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

	NSLog(@"%llu", res);
}

@end
