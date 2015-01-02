//
//  RocksDBBlockBasedTableOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBBlockBasedTableOptions.h"

#import <rocksdb/table.h>
#import <rocksdb/filter_policy.h>

@interface RocksDBCache ()
@property (nonatomic, assign) std::shared_ptr<rocksdb::Cache> cache;
@end

@interface RocksDBFilterPolicy ()
@property (nonatomic, assign) const rocksdb::FilterPolicy *filterPolicy;
@end

@interface RocksDBBlockBasedTableOptions ()
{
	rocksdb::BlockBasedTableOptions _options;

	RocksDBCache *_blockCacheWrapper;
	RocksDBCache *_blockCacheCompressedWrapper;
	RocksDBFilterPolicy *_filterPolicyWrapper;
}
@property (nonatomic, assign) rocksdb::BlockBasedTableOptions options;
@end

@implementation RocksDBBlockBasedTableOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::BlockBasedTableOptions();
	}
	return self;
}


#pragma mark - Accessor

- (void)setCacheIndexAndFilterBlocks:(BOOL)cacheIndexAndFilterBlocks
{
	_options.cache_index_and_filter_blocks = cacheIndexAndFilterBlocks;
}

- (BOOL)cacheIndexAndFilterBlocks
{
	return _options.cache_index_and_filter_blocks;
}

- (void)setIndexType:(BlockBasedTableIndexType)indexType
{
	_options.index_type = (rocksdb::BlockBasedTableOptions::IndexType)indexType;
}

- (BlockBasedTableIndexType)indexType
{
	return (BlockBasedTableIndexType)_options.index_type;
}

- (void)setHashIndexAllowCollision:(BOOL)hashIndexAllowCollision
{
	_options.hash_index_allow_collision = hashIndexAllowCollision;
}

- (BOOL)hashIndexAllowCollision
{
	return _options.hash_index_allow_collision;
}

- (void)setChecksumType:(BlockBasedTableChecksumType)checksumType
{
	_options.checksum = (rocksdb::ChecksumType)checksumType;
}

- (BlockBasedTableChecksumType)checksumType
{
	return (BlockBasedTableChecksumType)_options.checksum;
}

- (void)setNoBlockCache:(BOOL)noBlockCache
{
	_options.no_block_cache = noBlockCache;
}

- (BOOL)noBlockCache
{
	return _options.no_block_cache;
}

- (void)setBlockCache:(RocksDBCache *)blockCache
{
	_blockCacheWrapper = blockCache;
	_options.block_cache = _blockCacheWrapper.cache;
}

- (RocksDBCache *)blockCache
{
	return _blockCacheWrapper;
}

- (void)setBlockCacheCompressed:(RocksDBCache *)blockCacheCompressed
{
	_blockCacheCompressedWrapper = blockCacheCompressed;
	_options.block_cache = _blockCacheCompressedWrapper.cache;
}

- (RocksDBCache *)blockCacheCompressed
{
	return _blockCacheCompressedWrapper;
}

- (void)setBlockSize:(size_t)blockSize
{
	_options.block_size = blockSize;
}

- (size_t)blockSize
{
	return _options.block_size;
}

- (void)setBlockSizeDeviation:(int)blockSizeDeviation
{
	_options.block_size_deviation = blockSizeDeviation;
}

- (int)blockSizeDeviation
{
	return _options.block_size_deviation;
}

- (void)setBlockRestartInterval:(int)blockRestartInterval
{
	_options.block_restart_interval = blockRestartInterval;
}

- (int)blockRestartInterval
{
	return _options.block_restart_interval;
}

- (void)setFilterPolicy:(RocksDBFilterPolicy *)filterPolicy
{
	_filterPolicyWrapper = filterPolicy;
	_options.filter_policy.reset(_filterPolicyWrapper.filterPolicy);
}

- (RocksDBFilterPolicy *)filterPolicy
{
	return _filterPolicyWrapper;
}

- (void)setWholeKeyFiltering:(BOOL)wholeKeyFiltering
{
	_options.whole_key_filtering = wholeKeyFiltering;
}

- (BOOL)wholeKeyFiltering
{
	return _options.whole_key_filtering;
}

@end
