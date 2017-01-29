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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:_backupPath];

	XCTAssertTrue(exists);
}

- (void)testBackup_BackupInfo
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
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
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 10".data forKey:@"key 1".data error:nil];
	[_rocks setData:@"value 20".data forKey:@"key 2".data error:nil];
	[_rocks setData:@"value 30".data forKey:@"key 3".data error:nil];

	[_rocks close];

	[backupEngine restoreBackupToDestinationPath:_restorePath error:nil];

	RocksDB *backupRocks = [RocksDB databaseAtPath:_restorePath andDBOptions:nil];

	XCTAssertEqualObjects([backupRocks dataForKey:@"key 1".data error:nil], @"value 1".data);
	XCTAssertEqualObjects([backupRocks dataForKey:@"key 2".data error:nil], @"value 2".data);
	XCTAssertEqualObjects([backupRocks dataForKey:@"key 3".data error:nil], @"value 3".data);

	[backupRocks close];
}

- (void)testBackup_Restore_Specific
{
	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
	}];

	RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:_backupPath];

	[_rocks setData:@"value 1".data forKey:@"key 1".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 2".data forKey:@"key 2".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks setData:@"value 3".data forKey:@"key 3".data error:nil];
	[backupEngine createBackupForDatabase:_rocks error:nil];

	[_rocks close];

	[backupEngine restoreBackupWithId:1 toDestinationPath:_restorePath error:nil];

	RocksDB *backupRocks = [RocksDB databaseAtPath:_restorePath andDBOptions:nil];

	XCTAssertEqualObjects([backupRocks dataForKey:@"key 1".data error:nil], @"value 1".data);
	XCTAssertEqualObjects([backupRocks dataForKey:@"key 2".data error:nil], nil);
	XCTAssertEqualObjects([backupRocks dataForKey:@"key 3".data error:nil], nil);

	[backupRocks close];

	[backupEngine restoreBackupWithId:2 toDestinationPath:_restorePath error:nil];

	backupRocks = [RocksDB databaseAtPath:_restorePath andDBOptions:nil];

	XCTAssertEqualObjects([backupRocks dataForKey:@"key 1".data error:nil], @"value 1".data);
	XCTAssertEqualObjects([backupRocks dataForKey:@"key 2".data error:nil], @"value 2".data);
	XCTAssertEqualObjects([backupRocks dataForKey:@"key 3".data error:nil], nil);

	[backupRocks close];
}

@end
