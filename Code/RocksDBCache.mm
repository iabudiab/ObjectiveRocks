//
//  RocksDBCache.m
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBCache.h"

#import <rocksdb/cache.h>

@interface RocksDBCache ()
{
	std::shared_ptr<rocksdb::Cache> _cache;
}
@property (nonatomic, assign) std::shared_ptr<rocksdb::Cache> cache;
@end

@implementation RocksDBCache
@synthesize cache = _cache;

+ (instancetype)LRUCacheWithCapacity:(size_t)capacity
{
	return [[RocksDBCache alloc] initWithNativeCache:rocksdb::NewLRUCache(capacity)];
}

+ (instancetype)LRUCacheWithCapacity:(size_t)capacity numShardsBits:(int)numShardBits
{
	return [[RocksDBCache alloc] initWithNativeCache:rocksdb::NewLRUCache(capacity, numShardBits)];
}

- (instancetype)initWithNativeCache:(std::shared_ptr<rocksdb::Cache>)cache
{
	self = [super init];
	if (self) {
		_cache = cache;
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_cache != nullptr) {
			_cache.reset();
		}
	}
}

@end
