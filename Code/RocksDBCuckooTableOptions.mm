//
//  RocksDBCuckooTableOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBCuckooTableOptions.h"

#import <rocksdb/table.h>

@interface RocksDBCuckooTableOptions ()
{
	rocksdb::CuckooTableOptions _options;
}
@property (nonatomic, assign) rocksdb::CuckooTableOptions options;
@end

@implementation RocksDBCuckooTableOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::CuckooTableOptions();
	}
	return self;
}

#pragma mark - Accessor

- (void)setHashTableRatio:(double)hashTableRatio
{
	_options.hash_table_ratio = hashTableRatio;
}

- (double)hashTableRatio
{
	return _options.hash_table_ratio;
}

- (void)setMaxSearchDepth:(uint32_t)maxSearchDepth
{
	_options.max_search_depth = maxSearchDepth;
}

- (uint32_t)maxSearchDepth
{
	return _options.max_search_depth;
}

- (void)setCuckooBlockSize:(uint32_t)cuckooBlockSize
{
	_options.cuckoo_block_size = cuckooBlockSize;
}

- (uint32_t)cuckooBlockSize
{
	return _options.cuckoo_block_size;
}

- (void)setIdentityAsFirstHash:(BOOL)identityAsFirstHash
{
	_options.identity_as_first_hash	= identityAsFirstHash;
}

- (BOOL)identityAsFirstHash
{
	return _options.identity_as_first_hash;
}

- (void)setUseModuleHash:(BOOL)useModuleHash
{
	_options.use_module_hash = useModuleHash;
}

- (BOOL)useModuleHash
{
	return _options.use_module_hash;
}

@end
