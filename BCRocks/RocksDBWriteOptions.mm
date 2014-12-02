//
//  RocksDBWriteOptions.m
//  BCRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBWriteOptions.h"
#import <rocksdb/options.h>

@interface RocksDBWriteOptions ()
{
	rocksdb::WriteOptions _writeOptions;
}
@property (nonatomic, assign) rocksdb::WriteOptions options;
@end

@implementation RocksDBWriteOptions

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_writeOptions = rocksdb::WriteOptions();
	}
	return self;
}

#pragma mark - Accessor

- (BOOL)syncWrites
{
	return _writeOptions.sync;
}

- (void)setSyncWrites:(BOOL)syncWrites
{
	_writeOptions.sync = syncWrites;
}

- (BOOL)disableWriteAheadLog
{
	return _writeOptions.disableWAL;
}

- (void)setDisableWriteAheadLog:(BOOL)disableWriteAheadLog
{
	_writeOptions.disableWAL = disableWriteAheadLog;
}

- (uint64_t)timeoutHint
{
	return _writeOptions.timeout_hint_us;
}

- (void)setTimeoutHint:(uint64_t)timeoutHint
{
	_writeOptions.timeout_hint_us = timeoutHint;
}

- (BOOL)ignoreMissingColumnFamilies
{
	return _writeOptions.ignore_missing_column_families;
}

- (void)setIgnoreMissingColumnFamilies:(BOOL)ignoreMissingColumnFamilies
{
	_writeOptions.ignore_missing_column_families = ignoreMissingColumnFamilies;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	RocksDBWriteOptions *copy = [RocksDBWriteOptions new];
	copy.options = self.options;
	return copy;
}

@end
