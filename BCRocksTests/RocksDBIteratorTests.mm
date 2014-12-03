//
//  RocksDBIteratorTests.m
//  BCRocks
//
//  Created by Iska on 04/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BCRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Str(x)	[[NSString alloc] initWithData:x encoding:NSUTF8StringEncoding]

@interface RocksDBIteratorTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBIteratorTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] resourcePath];
	_path = [_path stringByAppendingPathComponent:@"BCRocks"];
}

- (void)tearDown
{
	NSString * path = [[NSBundle bundleForClass:[self class]] resourcePath];
	path = [path stringByAppendingPathComponent:@"BCRocks"];

	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	if (error) {
		NSLog(@"Error test teardown: %@", [error debugDescription]);
	}
	[super tearDown];
}

- (void)testDB_Iterator
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSMutableArray *expected = [NSMutableArray array];
	[_rocks enumerateKeysUsingBlock:^(id key, BOOL *stop) {
		[expected addObject:Str(key)];
	}];

	NSArray *actual = @[ @"key 1", @"key 2", @"key 3" ];
	XCTAssertEqualObjects(actual, expected);
}

@end
