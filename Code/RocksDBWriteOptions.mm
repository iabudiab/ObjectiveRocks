//
//  RocksDBWriteOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBWriteOptions.h"
#import <rocksdb/options.h>

@interface RocksDBWriteOptions ()
{
	rocksdb::WriteOptions _options;
}
@property (nonatomic, assign) rocksdb::WriteOptions options;
@end

@implementation RocksDBWriteOptions

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::WriteOptions();
	}
	return self;
}

#pragma mark - Accessor

- (BOOL)syncWrites
{
	return _options.sync;
}

- (void)setSyncWrites:(BOOL)syncWrites
{
	_options.sync = syncWrites;
}

- (BOOL)disableWriteAheadLog
{
	return _options.disableWAL;
}

- (void)setDisableWriteAheadLog:(BOOL)disableWriteAheadLog
{
	_options.disableWAL = disableWriteAheadLog;
}

- (BOOL)ignoreMissingColumnFamilies
{
	return _options.ignore_missing_column_families;
}

- (void)setIgnoreMissingColumnFamilies:(BOOL)ignoreMissingColumnFamilies
{
	_options.ignore_missing_column_families = ignoreMissingColumnFamilies;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	RocksDBWriteOptions *copy = [RocksDBWriteOptions new];
	copy.options = self.options;
	return copy;
}

@end
