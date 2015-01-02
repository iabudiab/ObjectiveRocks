//
//  RocksDBBackupEngine.m
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBBackupEngine.h"
#import "RocksDBError.h"

#undef ROCKSDB_LITE

#include <rocksdb/db.h>
#include <rocksdb/utilities/backupable_db.h>

@interface RocksDB (Private)
@property (nonatomic, assign) rocksdb::DB *db;
@end

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

@end
