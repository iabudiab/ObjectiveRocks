//
//  RocksDBTests.m
//  ObjectiveRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Str(x)	[[NSString alloc] initWithData:x encoding:NSUTF8StringEncoding]

@interface RocksDBTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end

@implementation RocksDBTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] resourcePath];
	_path = [_path stringByAppendingPathComponent:@"ObjectiveRocks"];
}

- (void)tearDown
{
	[_rocks close];

	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:_path error:&error];
	if (error) {
		NSLog(@"Error test teardown: %@", [error debugDescription]);
	}
	[super tearDown];
}

- (void)testDB_Open_ErrorIfExists
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
	[_rocks close];

	RocksDB *db = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.errorIfExists = YES;
	}];

	XCTAssertNil(db);
}

- (void)testDB_CRUD
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
	[_rocks setDefaultReadOptions:^(RocksDBReadOptions *readOptions) {
		readOptions.fillCache = YES;
		readOptions.verifyChecksums = YES;
	} andWriteOptions:^(RocksDBWriteOptions *writeOptions) {
		writeOptions.syncWrites = YES;
	}];


	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	XCTAssertEqualObjects([_rocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"key 2")], Data(@"value 2"));
	XCTAssertEqualObjects([_rocks dataForKey:Data(@"key 3")], Data(@"value 3"));

	[_rocks deleteDataForKey:Data(@"key 2")];
	XCTAssertNil([_rocks dataForKey:Data(@"key 2")]);

	NSError *error = nil;
	BOOL ok = [_rocks deleteDataForKey:Data(@"key 2") error:&error];
	XCTAssertTrue(ok);
	XCTAssertNil(error);
}

@end
