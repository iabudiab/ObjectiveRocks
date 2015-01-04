//
//  RocksDBColumnFamilyOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyOptions.h"
#import "RocksDBEncodingOptions.h"

#import <rocksdb/options.h>
#import <rocksdb/comparator.h>
#import <rocksdb/merge_operator.h>
#import <rocksdb/slice_transform.h>
#import <rocksdb/memtablerep.h>
#import <rocksdb/table.h>

@class RocksDBOptions;

@interface RocksDBComparator ()
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@interface RocksDBMergeOperator ()
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

@interface RocksDBPrefixExtractor ()
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
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
	RocksDBEncodingOptions *_encodingOptions;

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
		_encodingOptions = [RocksDBEncodingOptions new];
		_options = rocksdb::ColumnFamilyOptions();
	}
	return self;
}

#pragma mark - Encoding Options

-(id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([_encodingOptions respondsToSelector:aSelector]) {
		return _encodingOptions;
	}

	return nil;
}

#pragma mark - Column Family Options

- (void)setComparator:(RocksDBComparator *)comparator
{
	_comparatorWrapper = comparator;
	_comparatorWrapper.encodingOptions = _encodingOptions;
	_options.comparator = _comparatorWrapper.comparator;
}

- (RocksDBComparator *)comparator
{
	return _comparatorWrapper;
}

- (void)setMergeOperator:(RocksDBMergeOperator *)mergeOperator
{
	_mergeOperatorWrapper = mergeOperator;
	_mergeOperatorWrapper.encodingOptions = _encodingOptions;
	_options.merge_operator.reset(_mergeOperatorWrapper.mergeOperator);
}

- (RocksDBMergeOperator *)mergeOperator
{
	return _mergeOperatorWrapper;
}

- (void)setPrefixExtractor:(RocksDBPrefixExtractor *)prefixExtractor
{
	_prefixExtractorWrapper = prefixExtractor;
	_prefixExtractorWrapper.encodingOptions = _encodingOptions;
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

- (void)setMaxMemCompactionLevel:(int)maxMemCompactionLevel
{
	_options.max_mem_compaction_level = maxMemCompactionLevel;
}

- (int)maxMemCompactionLevel
{
	return _options.max_mem_compaction_level;
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

- (void)setExpandedCompactionFactor:(int)expandedCompactionFactor
{
	_options.expanded_compaction_factor = expandedCompactionFactor;
}

- (int)expandedCompactionFactor
{
	return _options.expanded_compaction_factor;
}

- (void)setSourceCompactionFactor:(int)sourceCompactionFactor
{
	_options.source_compaction_factor = sourceCompactionFactor;
}

- (int)sourceCompactionFactor
{
	return _options.source_compaction_factor;
}

- (void)setMaxGrandparentOverlapFactor:(int)maxGrandparentOverlapFactor
{
	_options.max_grandparent_overlap_factor = maxGrandparentOverlapFactor;
}

- (int)maxGrandparentOverlapFactor
{
	return _options.max_grandparent_overlap_factor;
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

- (void)setRateLimitDelayMaxMilliseconds:(unsigned int)rateLimitDelayMaxMilliseconds
{
	_options.rate_limit_delay_max_milliseconds = rateLimitDelayMaxMilliseconds;
}

- (unsigned int)rateLimitDelayMaxMilliseconds
{
	return _options.rate_limit_delay_max_milliseconds;
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

- (void)setVerifyChecksumsInCompaction:(BOOL)verifyChecksumsInCompaction
{
	_options.verify_checksums_in_compaction = verifyChecksumsInCompaction;
}

- (BOOL)verifyChecksumsInCompaction
{
	return _options.verify_checksums_in_compaction;
}

- (void)setFilterDeletes:(BOOL)filterDeletes
{
	_options.filter_deletes = filterDeletes;
}

- (BOOL)filterDeletes
{
	return _options.filter_deletes;
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

- (void)setMemtablePrefixBloomBits:(uint32_t)memtablePrefixBloomBits
{
	_options.memtable_prefix_bloom_bits = memtablePrefixBloomBits;
}

- (uint32_t)memtablePrefixBloomBits
{
	return _options.memtable_prefix_bloom_bits;
}

- (void)setMemtablePrefixBloomProbes:(uint32_t)memtablePrefixBloomProbes
{
	_options.memtable_prefix_bloom_probes = memtablePrefixBloomProbes;
}

- (uint32_t)memtablePrefixBloomProbes
{
	return _options.memtable_prefix_bloom_probes;
}

- (void)setMemtablePrefixBloomHugePageTlbSize:(size_t)memtablePrefixBloomHugePageTlbSize
{
	_options.memtable_prefix_bloom_huge_page_tlb_size = memtablePrefixBloomHugePageTlbSize;
}

- (size_t)memtablePrefixBloomHugePageTlbSize
{
	return _options.memtable_prefix_bloom_huge_page_tlb_size;
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

- (void)setMinPartialMergeOperands:(uint32_t)minPartialMergeOperands
{
	_options.min_partial_merge_operands = minPartialMergeOperands;
}

- (uint32_t)minPartialMergeOperands
{
	return _options.min_partial_merge_operands;
}

@end
