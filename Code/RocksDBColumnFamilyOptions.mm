//
//  RocksDBColumnFamilyOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyOptions.h"

#import "RocksDBMemTableRepFactory.h"
#import "RocksDBTableFactory.h"
#import "RocksDBComparator.h"
#import "RocksDBMergeOperator.h"
#import "RocksDBPrefixExtractor.h"

#import <rocksdb/options.h>
#import <rocksdb/comparator.h>
#import <rocksdb/merge_operator.h>
#import <rocksdb/slice_transform.h>
#import <rocksdb/memtablerep.h>
#import <rocksdb/table.h>

@class RocksDBOptions;

@interface RocksDBComparator ()
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@interface RocksDBMergeOperator ()
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

@interface RocksDBPrefixExtractor ()
@property (nonatomic, assign) const rocksdb::SliceTransform *sliceTransform;
@end

@interface RocksDBMemTableRepFactory ()
@property (nonatomic, assign) rocksdb::MemTableRepFactory *memTableRepFactory;
@end

@interface RocksDBTableFactory ()
@property (nonatomic, assign) rocksdb::TableFactory *tableFactory;
@end

@interface RocksDBColumnFamilyOptions ()
{
	rocksdb::ColumnFamilyOptions _options;

	RocksDBComparator *_comparatorWrapper;
	RocksDBMergeOperator *_mergeOperatorWrapper;
	RocksDBPrefixExtractor *_prefixExtractorWrapper;

	RocksDBMemTableRepFactory *_memTableRepFactoryWrapper;
	RocksDBTableFactory *_tableFactoryWrapper;
}
@property (nonatomic, assign) rocksdb::ColumnFamilyOptions options;
@end

@implementation RocksDBColumnFamilyOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::ColumnFamilyOptions();
	}
	return self;
}

#pragma mark - Column Family Options

- (void)setComparator:(RocksDBComparator *)comparator
{
	_comparatorWrapper = comparator;
	_options.comparator = _comparatorWrapper.comparator;
}

- (RocksDBComparator *)comparator
{
	return _comparatorWrapper;
}

- (void)setMergeOperator:(RocksDBMergeOperator *)mergeOperator
{
	_mergeOperatorWrapper = mergeOperator;
	_options.merge_operator.reset(_mergeOperatorWrapper.mergeOperator);
}

- (RocksDBMergeOperator *)mergeOperator
{
	return _mergeOperatorWrapper;
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

- (void)setMinWriteBufferNumberToMerge:(int)minWriteBufferNumberToMerge
{
	_options.min_write_buffer_number_to_merge = minWriteBufferNumberToMerge;
}

- (int)minWriteBufferNumberToMerge
{
	return _options.min_write_buffer_number_to_merge;
}

- (RocksDBCompressionType)compressionType
{
	return (RocksDBCompressionType)_options.compression;
}

- (void)setCompressionType:(RocksDBCompressionType)compressionType
{
	_options.compression = (rocksdb::CompressionType)compressionType;
}

- (void)setPrefixExtractor:(RocksDBPrefixExtractor *)prefixExtractor
{
	_prefixExtractorWrapper = prefixExtractor;
	_options.prefix_extractor.reset(_prefixExtractorWrapper.sliceTransform);
}

- (RocksDBPrefixExtractor *)prefixExtractor
{
	return _prefixExtractorWrapper;
}

- (void)setNumLevels:(int)numLevels
{
	_options.num_levels = numLevels;
}

- (int)numLevels
{
	return _options.num_levels;
}

- (void)setLevel0FileNumCompactionTrigger:(int)level0FileNumCompactionTrigger
{
	_options.level0_file_num_compaction_trigger = level0FileNumCompactionTrigger;
}

- (void)setLevel0SlowdownWritesTrigger:(int)level0SlowdownWritesTrigger
{
	_options.level0_slowdown_writes_trigger = level0SlowdownWritesTrigger;
}

- (int)level0SlowdownWritesTrigger
{
	return _options.level0_slowdown_writes_trigger;
}

- (void)setLevel0StopWritesTrigger:(int)level0StopWritesTrigger
{
	_options.level0_stop_writes_trigger = level0StopWritesTrigger;
}

- (int)level0StopWritesTrigger
{
	return _options.level0_stop_writes_trigger;
}

- (void)setTargetFileSizeBase:(uint64_t)targetFileSizeBase
{
	_options.target_file_size_base = targetFileSizeBase;
}

- (uint64_t)targetFileSizeBase
{
	return _options.target_file_size_base;
}

- (void)setTargetFileSizeMultiplier:(int)targetFileSizeMultiplier
{
	_options.target_file_size_multiplier = targetFileSizeMultiplier;
}

- (int)targetFileSizeMultiplier
{
	return _options.target_file_size_multiplier;
}

- (void)setMaxBytesForLevelBase:(uint64_t)maxBytesForLevelBase
{
	_options.max_bytes_for_level_base = maxBytesForLevelBase;
}

- (uint64_t)maxBytesForLevelBase
{
	return _options.max_bytes_for_level_base;
}

- (void)setMaxBytesForLevelMultiplier:(int)maxBytesForLevelMultiplier
{
	_options.max_bytes_for_level_multiplier = maxBytesForLevelMultiplier;
}

- (int)maxBytesForLevelMultiplier
{
	return _options.max_bytes_for_level_multiplier;
}

- (void)setSoftRateLimit:(double)softRateLimit
{
	_options.soft_rate_limit = softRateLimit;
}

- (double)softRateLimit
{
	return _options.soft_rate_limit;
}

- (void)setHardRateLimit:(double)hardRateLimit
{
	_options.hard_rate_limit = hardRateLimit;
}

- (double)hardRateLimit
{
	return _options.hard_rate_limit;
}

- (void)setArenaBlockSize:(size_t)arenaBlockSize
{
	_options.arena_block_size = arenaBlockSize;
}

- (size_t)arenaBlockSize
{
	return _options.arena_block_size;
}

- (void)setDisableAutoCompactions:(BOOL)disableAutoCompactions
{
	_options.disable_auto_compactions = disableAutoCompactions;
}

- (BOOL)disableAutoCompactions
{
	return _options.disable_auto_compactions;
}

- (void)setPurgeRedundantKvsWhileFlush:(BOOL)purgeRedundantKvsWhileFlush
{
	_options.purge_redundant_kvs_while_flush = purgeRedundantKvsWhileFlush;
}

- (BOOL)purgeRedundantKvsWhileFlush
{
	return _options.purge_redundant_kvs_while_flush;
}

- (void)setMaxSequentialSkipInIterations:(uint64_t)maxSequentialSkipInIterations
{
	_options.max_sequential_skip_in_iterations = maxSequentialSkipInIterations;
}

- (uint64_t)maxSequentialSkipInIterations
{
	return _options.max_sequential_skip_in_iterations;
}

- (void)setMemTableRepFactory:(RocksDBMemTableRepFactory *)memTableRepFactory
{
	_memTableRepFactoryWrapper = memTableRepFactory;
	_options.memtable_factory.reset(_memTableRepFactoryWrapper.memTableRepFactory);
}

- (RocksDBMemTableRepFactory *)memTableRepFactory
{
	return _memTableRepFactoryWrapper;
}

- (void)setTableFacotry:(RocksDBTableFactory *)tableFacotry
{
	_tableFactoryWrapper = tableFacotry;
	_options.table_factory.reset(_tableFactoryWrapper.tableFactory);
}

- (RocksDBTableFactory *)tableFacotry
{
	return _tableFactoryWrapper;
}

- (void)setMemtablePrefixBloomSizeRatio:(double)memtablePrefixBloomSizeRatio
{
	_options.memtable_prefix_bloom_size_ratio = memtablePrefixBloomSizeRatio;
}

- (double)memtablePrefixBloomSizeRatio
{
	return _options.memtable_prefix_bloom_size_ratio;
}

- (void)setMemtableHugePageTlbSize:(size_t)memtableHugePageTlbSize
{
	_options.memtable_huge_page_size = memtableHugePageTlbSize;
}

- (size_t)memtableHugePageTlbSize
{
	return _options.memtable_huge_page_size;
}

- (void)setBloomLocality:(uint32_t)bloomLocality
{
	_options.bloom_locality = bloomLocality;
}

- (uint32_t)bloomLocality
{
	return _options.bloom_locality;
}

- (void)setMaxSuccessiveMerges:(size_t)maxSuccessiveMerges
{
	_options.max_successive_merges = maxSuccessiveMerges;
}

- (size_t)maxSuccessiveMerges
{
	return _options.max_successive_merges;
}

@end
