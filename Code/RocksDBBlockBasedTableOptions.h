//
//  RocksDBBlockBasedTableOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBCache.h"
#import "RocksDBFilterPolicy.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(char, BlockBasedTableIndexType)
{

	/**
	 @brief A space efficient index block that is optimized for
	 binary-search-based index.
	 */
	BlockBasedTableIndexBinarySearch,

	/**
	 @brief The hash index, if enabled, will do the hash lookup when
	 a prefix extractor is provided.
	 
	 @see RocksDBPrefixExtractor
	 */
	BlockBasedTableIndexHashSearch
};

typedef NS_ENUM(char, BlockBasedTableChecksumType) {
	BlockBasedTableNoChecksum = 0x0,  // not yet supported. Will fail
	BlockBasedTableChecksumCRC32c = 0x1,
	BlockBasedTableChecksumxxHash = 0x2,
};

@interface RocksDBBlockBasedTableOptions : NSObject

/**
 @brief
 Indicate to put index/filter blocks to the block cache.
 If not specified, each "table reader" object will pre-load index/filter
 block during table initialization.
 */
@property (nonatomic, assign) BOOL cacheIndexAndFilterBlocks;

/**
 @brief The index type that will be used for this table.
 */
@property (nonatomic, assign) BlockBasedTableIndexType indexType;

/**
 @brief 
  Influence the behavior when kHashSearch is used.
  if false, stores a precise prefix to block range mapping
  if true, does not store prefix and allows prefix hash collision
  (less memory consumption)
 */
@property (nonatomic, assign) BOOL hashIndexAllowCollision;

/**
 @brief
  Use the specified checksum type. Newly created table files will be
  protected with this checksum type. Old table files will still be readable,
  even though they have different checksum type.
 */
@property (nonatomic, assign) BlockBasedTableChecksumType checksumType;

/**
 @brief
  Disable block cache. If this is set to true,
  then no block cache should be used, and the block_cache should
  point to a nullptr object.
 */
@property (nonatomic, assign) BOOL noBlockCache;

/**
 @brief
  Use the specified cache for blocks.
  If nil, rocksdb will automatically create and use an 8MB internal cache.
 
 @see RocksDBCache
 */
@property (nonatomic, strong, nullable) RocksDBCache *blockCache;

/**
 @brief
  Use the specified cache for compressed blocks.

 @see RocksDBCache
 */
@property (nonatomic, strong, nullable) RocksDBCache *blockCacheCompressed;

/**
 @brief
  Approximate size of user data packed per block.  Note that the
  block size specified here corresponds to uncompressed data. The
  actual size of the unit read from disk may be smaller if
  compression is enabled.  This parameter can be changed dynamically.
 */
@property (nonatomic, assign) size_t blockSize;

/**
 @brief
  This is used to close a block before it reaches the configured
  'blockSize'. If the percentage of free space in the current block is less
  than this specified number and adding a new record to the block will
  exceed the configured block size, then this block will be closed and the
  new record will be written to the next block.
 */
@property (nonatomic, assign) int blockSizeDeviation;

/**
 @brief
  Number of keys between restart points for delta encoding of keys.
  This parameter can be changed dynamically.
 */
@property (nonatomic, assign) int blockRestartInterval;

/**
 @brief
  Use the specified filter policy to reduce disk reads.

 @see RocksDBFilterPolicy
 */
@property (nonatomic, strong, nullable) RocksDBFilterPolicy *filterPolicy;

/**
 @brief
  If true, place whole keys in the filter (not just prefixes).
  This must generally be true for gets to be efficient.
 */
@property (nonatomic, assign) BOOL wholeKeyFiltering;

@end

NS_ASSUME_NONNULL_END
