//
//  RocksDBDatabaseOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBDatabaseOptions.h"

#import "RocksDBEnv.h"
#import <rocksdb/options.h>

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))
#import "RocksDBStatistics.h"
@interface RocksDBStatistics ()
@property (nonatomic, assign) std::shared_ptr<rocksdb::Statistics> statistics;
@end
#endif

@interface RocksDBDatabaseOptions ()
{
	rocksdb::DBOptions _options;

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))
	RocksDBStatistics *_statisticsWrapper;
#endif
}
@property (nonatomic, assign) const rocksdb::DBOptions options;
@end

@implementation RocksDBDatabaseOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::DBOptions();
	}
	return self;
}

#pragma mark - DB Options

- (BOOL)createIfMissing
{
	return _options.create_if_missing;
}

- (void)setCreateIfMissing:(BOOL)createIfMissing
{
	_options.create_if_missing = createIfMissing;
}

- (BOOL)createMissingColumnFamilies
{
	return _options.create_missing_column_families;
}

- (void)setCreateMissingColumnFamilies:(BOOL)createMissingColumnFamilies
{
	_options.create_missing_column_families = createMissingColumnFamilies;
}

- (BOOL)errorIfExists
{
	return _options.error_if_exists;
}

- (void)setErrorIfExists:(BOOL)errorIfExists
{
	_options.error_if_exists = errorIfExists;
}

- (BOOL)paranoidChecks
{
	return _options.paranoid_checks;
}

- (void)setParanoidChecks:(BOOL)paranoidChecks
{
	_options.paranoid_checks = paranoidChecks;
}

- (RocksDBLogLevel)infoLogLevel
{
	return (RocksDBLogLevel)_options.info_log_level;
}

- (void)setInfoLogLevel:(RocksDBLogLevel)infoLogLevel
{
	_options.info_log_level = (rocksdb::InfoLogLevel)infoLogLevel;
}

- (int)maxOpenFiles
{
	return _options.max_open_files;
}

- (void)setMaxOpenFiles:(int)maxOpenFiles
{
	_options.max_open_files = maxOpenFiles;
}

- (uint64_t)maxWriteAheadLogSize
{
	return _options.max_total_wal_size;
}

- (void)setMaxWriteAheadLogSize:(uint64_t)maxWriteAheadLogSize
{
	_options.max_total_wal_size	= maxWriteAheadLogSize;
}

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))
- (RocksDBStatistics *)statistics
{
	return _statisticsWrapper;
}

- (void)setStatistics:(RocksDBStatistics *)statistics
{
	_statisticsWrapper = statistics;
	_options.statistics = _statisticsWrapper.statistics;
}
#endif

- (BOOL)useFSync
{
	return _options.use_fsync;
}

- (void)setUseFSync:(BOOL)useFSync
{
	_options.use_fsync = useFSync;
}

- (size_t)maxLogFileSize
{
	return _options.max_log_file_size;
}

- (void)setMaxLogFileSize:(size_t)maxLogFileSize
{
	_options.max_log_file_size = maxLogFileSize;
}

- (size_t)logFileTimeToRoll
{
	return _options.log_file_time_to_roll;
}

- (void)setLogFileTimeToRoll:(size_t)logFileTimeToRoll
{
	_options.log_file_time_to_roll = logFileTimeToRoll;
}

- (size_t)keepLogFileNum
{
	return _options.keep_log_file_num;
}

- (void)setKeepLogFileNum:(size_t)keepLogFileNum
{
	_options.keep_log_file_num = keepLogFileNum;
}

- (uint64_t)bytesPerSync
{
	return _options.bytes_per_sync;
}

- (void)setBytesPerSync:(uint64_t)bytesPerSync
{
	_options.bytes_per_sync = bytesPerSync;
}

@end
