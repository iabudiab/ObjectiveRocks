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

- (void)createBackupForDatabase:(RocksDB *)database
{
	_backupEngine->CreateNewBackup(database.db);
}

- (void)restoreBackupToDestinationPath:(NSString *)destination
{
	_backupEngine->RestoreDBFromLatestBackup(destination.UTF8String, destination.UTF8String);
}

@end
