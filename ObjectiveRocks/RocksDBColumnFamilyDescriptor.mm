//
//  RocksDBColumnFamilyDescriptor.m
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyDescriptor.h"

#import <rocksdb/db.h>

NSString * const RocksDBDefaultColumnFamilyName = @"default";

@interface RocksDBColumnFamilyOptions ()
@property (nonatomic, assign) rocksdb::ColumnFamilyOptions options;
@end

@interface RocksDBColumnFamilyDescriptor ()
{
	std::vector<rocksdb::ColumnFamilyDescriptor> *_columnFamilies;
}
@property (nonatomic, assign) std::vector<rocksdb::ColumnFamilyDescriptor> *columnFamilies;
@end

@implementation RocksDBColumnFamilyDescriptor
@synthesize columnFamilies = _columnFamilies;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_columnFamilies = new std::vector<rocksdb::ColumnFamilyDescriptor>;
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_columnFamilies != NULL) {
			_columnFamilies->clear();
			delete _columnFamilies;
			_columnFamilies = NULL;
		}
	}
}

#pragma mark - Add Column Families

- (void)addDefaultColumnFamilyWithOptions:(void (^)(RocksDBColumnFamilyOptions *options))options
{
	[self addColumnFamilyWithName:RocksDBDefaultColumnFamilyName andOptions:options];
}

- (void)addColumnFamilyWithName:(NSString *)name andOptions:(void (^)(RocksDBColumnFamilyOptions *options))optionsBlock
{
	RocksDBColumnFamilyOptions *options = [RocksDBColumnFamilyOptions new];
	if (optionsBlock) {
		optionsBlock(options);
	}

	rocksdb::ColumnFamilyDescriptor descriptor = rocksdb::ColumnFamilyDescriptor(name.UTF8String, options.options);
	_columnFamilies->push_back(descriptor);
}

@end
