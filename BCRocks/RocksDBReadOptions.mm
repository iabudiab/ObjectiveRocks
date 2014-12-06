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
	rocksdb::ReadOptions _options;
}
@property (nonatomic, assign) rocksdb::ReadOptions options;
@end

@implementation RocksDBReadOptions

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::ReadOptions();
	}
	return self;
}

#pragma mark - Accessor

- (BOOL)verifyChecksums
{
	return _options.verify_checksums;
}

- (void)setVerifyChecksums:(BOOL)verifyChecksums
{
	_options.verify_checksums = verifyChecksums;
}

- (BOOL)fillCache
{
	return _options.fill_cache;
}

- (void)setFillCache:(BOOL)fillCache
{
	_options.fill_cache = fillCache;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	RocksDBReadOptions *copy = [RocksDBReadOptions new];
	copy.options = self.options;
	return copy;
}

@end
