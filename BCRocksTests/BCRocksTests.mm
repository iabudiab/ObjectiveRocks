//
//  BCRocksTests.m
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BCRocks.h"

@interface BCRocksTests : XCTestCase
{
	RocksDB *_rocks;
}
@end

@implementation BCRocksTests

- (void)setUp
{
	[super setUp];

	NSString * path = [[NSBundle bundleForClass:[self class]] resourcePath];
	path = [path stringByAppendingPathComponent:@"BCRocks"];
	_rocks = [[RocksDB alloc] initWithPath:path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];
}

- (void)tearDown
{
	[_rocks close];

	NSString * path = [[NSBundle bundleForClass:[self class]] resourcePath];
	path = [path stringByAppendingPathComponent:@"BCRocks"];

	NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	if (error) {
		NSLog(@"Error test teardown: %@", [error debugDescription]);
	}
	[super tearDown];
}

- (void)testDB_Init
{
	NSString *key = @"key";
	NSString *value = @"value";

	BOOL ok = [_rocks setData:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:[key dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssert(ok, @"Put Data");

	NSData *data = [_rocks dataForKey:[key dataUsingEncoding:NSUTF8StringEncoding]];
	XCTAssertNotNil(data);

	NSString *roundtrip = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	XCTAssertEqualObjects(roundtrip, value);
}

@end
