//
//  RocksDBOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBOptions.h"
#import "RocksDBComparator.h"

#import <rocksdb/options.h>
#import <rocksdb/comparator.h>
#import <rocksdb/merge_operator.h>
#import <rocksdb/slice_transform.h>

#include <rocksdb/filter_policy.h>
#include <rocksdb/table.h>

@interface RocksDBComparator ()
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@interface RocksDBMergeOperator ()
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

@interface RocksDBPrefixExtractor ()
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, assign) const rocksdb::SliceTransform *sliceTransform;
@end

@interface RocksDBOptions ()
{
	rocksdb::Options _options;
	RocksDBComparator *_comparatorWrapper;
	RocksDBMergeOperator *_mergeOperatorWrapper;
	RocksDBPrefixExtractor *_prefixExtractorWrapper;
}
@property (nonatomic, assign) rocksdb::Options options;
@end

@implementation RocksDBOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::Options();
		rocksdb::BlockBasedTableOptions table_options;
		table_options.filter_policy.reset(rocksdb::NewBloomFilterPolicy(10, true));
		_options.table_factory.reset(NewBlockBasedTableFactory(table_options));
	}
	return self;
}

#pragma mark - Types

- (void)setKeyType:(RocksDBType)type
{
	self.keyEncoder = [RocksDBTypes keyEncoderForType:type];
	self.keyDecoder = [RocksDBTypes keyDecoderForType:type];
	_keyType = type;
}

- (void)setValueType:(RocksDBType)type
{
	self.valueEncoder = [RocksDBTypes valueEncoderForType:type];
	self.valueDecoder = [RocksDBTypes valueDecoderForType:type];
	_valueType = type;
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

- (BOOL)disableDataSync
{
	return _options.disableDataSync;
}

- (void)setDisableDataSync:(BOOL)disableDataSync
{
	_options.disableDataSync = disableDataSync;
}

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

#pragma mark - Column Family Options

- (void)setComparator:(RocksDBComparator *)comparator
{
	_comparatorWrapper = comparator;
	_comparatorWrapper.options = self;
	_options.comparator = _comparatorWrapper.comparator;
}

- (RocksDBComparator *)comparator
{
	return _comparatorWrapper;
}

- (void)setMergeOperator:(RocksDBMergeOperator *)mergeOperator
{
	_mergeOperatorWrapper = mergeOperator;
	_mergeOperatorWrapper.options = self;
	_options.merge_operator.reset(_mergeOperatorWrapper.mergeOperator);
}

- (RocksDBMergeOperator *)mergeOperator
{
	return _mergeOperatorWrapper;
}

- (void)setPrefixExtractor:(RocksDBPrefixExtractor *)prefixExtractor
{
	_prefixExtractorWrapper = prefixExtractor;
	_prefixExtractorWrapper.options = self;
	_options.prefix_extractor.reset(_prefixExtractorWrapper.sliceTransform);
}

- (RocksDBPrefixExtractor *)prefixExtractor
{
	return _prefixExtractorWrapper;
}

- (size_t)writeBufferSize
{
	return _options.write_buffer_size;
}

- (void)setWriteBufferSize:(size_t)writeBufferSize
{
	_options.write_buffer_size = writeBufferSize;
}

- (int)maxWriteBufferNumber
{
	return _options.max_write_buffer_number;
}

- (void)setMaxWriteBufferNumber:(int)maxWriteBufferNumber
{
	_options.max_write_buffer_number = maxWriteBufferNumber;
}

- (RocksDBCompressionType)compressionType
{
	return (RocksDBCompressionType)_options.compression;
}

- (void)setCompressionType:(RocksDBCompressionType)compressionType
{
	_options.compression = (rocksdb::CompressionType)compressionType;
}

@end

