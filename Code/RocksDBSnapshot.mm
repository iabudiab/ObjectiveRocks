//
//  RocksDBSnapshot.m
//  ObjectiveRocks
//
//  Created by Iska on 06/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBSnapshot.h"
#import "RocksDB+Private.h"

#import <rocksdb/db.h>

@interface RocksDBReadOptions (Private)
@property (nonatomic, assign) rocksdb::ReadOptions options;
@end

@implementation RocksDBSnapshot

#pragma mark - Lifecycle

- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					andReadOptions:(RocksDBReadOptions *)readOptions
{
	self = [super init];
	if (self) {
		self.db = db;
		self.columnFamily = columnFamily;
		self.readOptions = readOptions;
	}
	return self;
}

- (void)close
{
	@synchronized(self) {
		rocksdb::ReadOptions options = self.readOptions.options;
		if (options.snapshot != nullptr) {
			self.db->ReleaseSnapshot(options.snapshot);
			options.snapshot = nullptr;
			self.readOptions.options = options;
		}
	}
}

#pragma mark - 

- (uint64_t)sequenceNumber
{
	return self.readOptions.options.snapshot->GetSequenceNumber();
}

@end
