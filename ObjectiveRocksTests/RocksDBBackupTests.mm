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

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:_backupPath];

	XCTAssertTrue(exists);
}

- (void)testBackup_BackupInfo
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	NSArray *backupInfo = [backupEngine backupInfo];

	XCTAssertNotNil(backupInfo);
	XCTAssertEqual(backupInfo.count, 1);

	RocksDBBackupInfo *info = backupInfo[0];

	XCTAssertEqual(info.backupId, 1);
}

- (void)testBackup_BackupInfo_Multiple
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	NSArray *backupInfo = [backupEngine backupInfo];

	XCTAssertNotNil(backupInfo);
	XCTAssertEqual(backupInfo.count, 3);

	XCTAssertEqual([backupInfo[0] backupId], 1);
	XCTAssertEqual([backupInfo[1] backupId], 2);
	XCTAssertEqual([backupInfo[2] backupId], 3);
}

- (void)testBackup_PurgeBackups
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	[backupEngine purgeOldBackupsKeepingLast:2 error:nil];

	NSArray *backupInfo = [backupEngine backupInfo];

	XCTAssertNotNil(backupInfo);
	XCTAssertEqual(backupInfo.count, 2);

	XCTAssertEqual([backupInfo[0] backupId], 2);
	XCTAssertEqual([backupInfo[1] backupId], 3);
}

- (void)testBackup_DeleteBackup
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	[backupEngine deleteBackupWithId:2 error:nil];

	NSArray *backupInfo = [backupEngine backupInfo];

	XCTAssertNotNil(backupInfo);
	XCTAssertEqual(backupInfo.count, 2);

	XCTAssertEqual([backupInfo[0] backupId], 1);
	XCTAssertEqual([backupInfo[1] backupId], 3);
}

- (void)testBackup_Restore
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 10") forKey:Data(@"key 1")];
	[_rocks setData:Data(@"value 20") forKey:Data(@"key 2")];
	[_rocks setData:Data(@"value 30") forKey:Data(@"key 3")];

	[_rocks close];

	[backupEngine restoreBackupToDestinationPath:_restorePath error:nil];

	RocksDB *backupRocks = [[RocksDB alloc] initWithPath:_restorePath];

	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 2")], Data(@"value 2"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 3")], Data(@"value 3"));

	[backupRocks close];
}

- (void)testBackup_Restore_Specific
{
	_rocks = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:Data(@"value 1") forKey:Data(@"key 1")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 2") forKey:Data(@"key 2")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:Data(@"value 3") forKey:Data(@"key 3")];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	[backupEngine restoreBackupWithId:1 toDestinationPath:_restorePath error:nil];

	RocksDB *backupRocks = [[RocksDB alloc] initWithPath:_restorePath];

	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 2")], nil);
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 3")], nil);

	[backupRocks close];

	[backupEngine restoreBackupWithId:2 toDestinationPath:_restorePath error:nil];

	backupRocks = [[RocksDB alloc] initWithPath:_restorePath];

	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 1")], Data(@"value 1"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 2")], Data(@"value 2"));
	XCTAssertEqualObjects([backupRocks dataForKey:Data(@"key 3")], nil);

	[backupRocks close];
}

@end
