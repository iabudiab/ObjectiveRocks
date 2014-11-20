//
//  RocksDBReadOptions.m
//  BCRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBReadOptions.h"

#import <rocksdb/options.h>

@interface RocksDBReadOptions ()
{
	rocksdb::ReadOptions _readOptions;
}
@end

@implementation RocksDBReadOptions

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_readOptions = rocksdb::ReadOptions();
	}
	return self;
}

#pragma mark - Accessor

- (BOOL)verifyChecksums
{
	return _readOptions.verify_checksums;
}

- (void)setVerifyChecksums:(BOOL)verifyChecksums
{
	_readOptions.verify_checksums = verifyChecksums;
}

- (BOOL)fillCache
{
	return _readOptions.fill_cache;
}

- (void)setFillCache:(BOOL)fillCache
{
	_readOptions.fill_cache = fillCache;
}

@end
