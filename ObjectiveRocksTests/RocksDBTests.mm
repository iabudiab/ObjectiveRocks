//
//  ObjectiveRocksTests.m
//  ObjectiveRocks
//
//  Created by Iska on 24/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@implementation RocksDBTests

- (void)setUp
{
	[super setUp];

	_path = [[NSBundle bundleForClass:[self class]] bundlePath];
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

@end
