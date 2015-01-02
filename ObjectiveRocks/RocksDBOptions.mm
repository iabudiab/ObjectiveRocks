//
//  RocksDBOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBOptions.h"

#import <rocksdb/options.h>
#import <rocksdb/comparator.h>
#import <rocksdb/merge_operator.h>
#import <rocksdb/slice_transform.h>

@interface RocksDBDatabaseOptions ()
@property (nonatomic, assign) const rocksdb::DBOptions options;
@end

@interface RocksDBColumnFamilyOptions ()
@property (nonatomic, assign) rocksdb::ColumnFamilyOptions options;
@end

@interface RocksDBOptions ()
{
	RocksDBDatabaseOptions *_databaseOptions;
	RocksDBColumnFamilyOptions *_columnFamilyOption;
}
@property (nonatomic, assign) rocksdb::Options options;
@property (nonatomic, strong) RocksDBDatabaseOptions *databaseOptions;
@property (nonatomic, strong) RocksDBColumnFamilyOptions *columnFamilyOption;
@end

@implementation RocksDBOptions
@synthesize databaseOptions = _databaseOptions;
@synthesize columnFamilyOption = _columnFamilyOption;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_databaseOptions = [RocksDBDatabaseOptions new];
		_columnFamilyOption = [RocksDBColumnFamilyOptions new];
	}
	return self;
}

- (instancetype)initWithDatabaseOptions:(RocksDBDatabaseOptions *)dbOptions
				 andColumnFamilyOptions:(RocksDBColumnFamilyOptions *)columnFamilyOptions
{
	self = [super init];
	if (self) {
		_databaseOptions = dbOptions;
		_columnFamilyOption = columnFamilyOptions;
	}
	return self;
}

#pragma mark - Property

- (rocksdb::Options)options
{
	return rocksdb::Options(_databaseOptions.options, _columnFamilyOption.options);
}

#pragma mark - Forward

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([_databaseOptions respondsToSelector:aSelector]) {
		return _databaseOptions;
	} else {
		return _columnFamilyOption;
	}
}

@end

