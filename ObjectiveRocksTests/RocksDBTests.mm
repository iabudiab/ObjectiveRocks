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

- (void)testDB_CRUD_Encoded
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.keyEncoder = ^ NSData * (id key) {
			return [key dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.keyDecoder = ^ NSString * (NSData *data) {
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
		options.valueEncoder = ^ NSData * (id key, id value) {
			return [value dataUsingEncoding:NSUTF8StringEncoding];
		};
		options.valueDecoder = ^ NSString * (id key, NSData * data) {
			if (data == nil) return nil;
			return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		};
	}];
	[_rocks setDefaultReadOptions:^(RocksDBReadOptions *readOptions) {
		readOptions.fillCache = YES;
		readOptions.verifyChecksums = YES;
	} andWriteOptions:^(RocksDBWriteOptions *writeOptions) {
		writeOptions.syncWrites = YES;
	}];


	[_rocks setObject:@"value 1" forKey:@"key 1"];
	[_rocks setObject:@"value 2" forKey:@"key 2"];
	[_rocks setObject:@"value 3" forKey:@"key 3"];

	XCTAssertEqualObjects([_rocks objectForKey:@"key 1"], @"value 1");
	XCTAssertEqualObjects([_rocks objectForKey:@"key 2"], @"value 2");
	XCTAssertEqualObjects([_rocks objectForKey:@"key 3"], @"value 3");

	[_rocks deleteObjectForKey:@"key 2"];
	XCTAssertNil([_rocks objectForKey:@"key 2"]);

	NSError *error = nil;
	BOOL ok = [_rocks deleteObjectForKey:@"key 2" error:&error];
	XCTAssertTrue(ok);
	XCTAssertNil(error);
}

@end
