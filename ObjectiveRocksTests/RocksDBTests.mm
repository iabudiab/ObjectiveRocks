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
	_backupPath = [_path stringByAppendingString:@"Backup"];
	_restorePath = [_path stringByAppendingString:@"Restore"];
	_chekpointPath_1 = [_path stringByAppendingPathComponent:@"Snapshot1"];
	_chekpointPath_2 = [_path stringByAppendingPathComponent:@"Snapshot2"];
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
	[[NSFileManager defaultManager] removeItemAtPath:_backupPath error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:_restorePath error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:_chekpointPath_1 error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:_chekpointPath_2 error:nil];
}

@end
