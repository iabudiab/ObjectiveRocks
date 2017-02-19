//
//  RocksDBCache.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 RocksDB cache.
 */
@interface RocksDBCache : NSObject

/**
 Create a new cache with a fixed size capacity. The cache is sharded
 to 2^numShardBits shards, by hash of the key. The total capacity
 is divided and evenly assigned to each shard. The default 
 numShardBits is 4.

 @see capacity The cache capcity.
 */
+ (instancetype)LRUCacheWithCapacity:(size_t)capacity;

/**
 Create a new cache with a fixed size capacity. The cache is sharded
 to 2^numShardBits shards, by hash of the key. The total capacity
 is divided and evenly assigned to each shard.

 @see capacity The cache capcity.
 @see numShardBits The number of shard bits.
 */
+ (instancetype)LRUCacheWithCapacity:(size_t)capacity numShardsBits:(int)numShardBits;

@end

NS_ASSUME_NONNULL_END
