//
//  RocksDBBackupTests.m
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBBackupTests : RocksDBTests

@end

@implementation RocksDBBackupTests

- (void)testBackup_Create
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSString *backupPath = [_path stringByAppendingString:@"Backup"];
	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:backupPath];

	[backupEngine createBackupForDatabase:_rocks error:nil];

	RocksDB *backupRocks = [[RocksDB alloc] initWithPath:backupPath];

	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 2")], Data(@"value 2"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 3")], Data(@"value 3"));
}

- (void)testBackup_Restore
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	NSString *backupPath = [_path stringByAppendingString:@"Backup"];
	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:backupPath];

	[_rocks setData:Data(@"value 10") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 20") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 30") forKey:Data(@"key 3")];

	[_rocks close];

	[backupEngine restoreBackupToDestinationPath:_path error:nil];

	RocksDB *backupRocks = [[RocksDB alloc] initWithPath:backupPath];

	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 2")], Data(@"value 2"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 3")], Data(@"value 3"));
}

@end
