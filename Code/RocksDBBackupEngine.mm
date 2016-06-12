//
//  RocksDBBackupEngine.m
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBBackupEngine.h"
#import "RocksDBError.h"
#import "RocksDBBackupInfo.h"

#include <rocksdb/db.h>
#include <rocksdb/utilities/backupable_db.h>

#pragma mark - Informal Protocols

@interface RocksDB ()
@property (nonatomic, assign) rocksdb::DB *db;
@end

@interface RocksDBBackupInfo ()
@property (nonatomic, assign) uint32_t backupId;
@property (nonatomic, assign) int64_t timestamp;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) uint32_t numberFiles;
@end

#pragma mark - Impl

@interface RocksDBBackupEngine ()
{
	NSString *_path;
	rocksdb::BackupEngine *_backupEngine;
}
@end

@implementation RocksDBBackupEngine

#pragma mark - Lifecycle 

- (instancetype)initWithPath:(NSString *)path
{
	self = [super init];
	if (self) {
		_path = [path copy];
		rocksdb::Status status = rocksdb::BackupEngine::Open(rocksdb::Env::Default(),
															 rocksdb::BackupableDBOptions::BackupableDBOptions(_path.UTF8String),
															 &_backupEngine);
		if (!status.ok()) {
			NSLog(@"Error opening database backup: %@", [RocksDBError errorWithRocksStatus:status]);
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[self close];
}

- (void)close
{
	@synchronized(self) {
		if (_backupEngine != NULL) {
			delete _backupEngine;
			_backupEngine = NULL;
		}
	}
}

#pragma mark - Backup & Restore

- (BOOL)createBackupForDatabase:(RocksDB *)database error:(NSError * __autoreleasing *)error
{
	rocksdb::Status status = _backupEngine->CreateNewBackup(database.db);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
			return NO;
		}
	}
	return YES;
}

- (BOOL)restoreBackupToDestinationPath:(NSString *)destination error:(NSError * __autoreleasing *)error
{
	rocksdb::Status status = _backupEngine->RestoreDBFromLatestBackup(destination.UTF8String, destination.UTF8String);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
			return NO;
		}
	}
	return YES;
}

- (BOOL)restoreBackupWithId:(uint32_t)backupId toDestinationPath:(NSString *)destination error:(NSError *__autoreleasing *)error
{
	rocksdb::Status status = _backupEngine->RestoreDBFromBackup(backupId, destination.UTF8String, destination.UTF8String);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
			return NO;
		}
	}
	return YES;
}

- (BOOL)purgeOldBackupsKeepingLast:(uint32_t)countBackups error:(NSError *__autoreleasing *)error
{
	rocksdb::Status status = _backupEngine->PurgeOldBackups(countBackups);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
			return NO;
		}
	}
	return YES;
}

- (BOOL)deleteBackupWithId:(uint32_t)backupId error:(NSError *__autoreleasing *)error
{
	rocksdb::Status status = _backupEngine->DeleteBackup(backupId);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
			return NO;
		}
	}
	return YES;
}

- (NSArray *)backupInfo
{
	std::vector<rocksdb::BackupInfo> backup_info;
	_backupEngine->GetBackupInfo(&backup_info);

	NSMutableArray *backupInfo = [NSMutableArray array];
	for (auto it = std::begin(backup_info); it != std::end(backup_info); ++it) {
		RocksDBBackupInfo *info = [RocksDBBackupInfo new];
		info.backupId = (*it).backup_id;
		info.timestamp = (*it).timestamp;
		info.size = (*it).size;
		info.numberFiles = (*it).number_files;
		[backupInfo addObject:info];
	}

	return backupInfo;
}

@end
