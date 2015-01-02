//
//  RocksDBColumnFamily.m
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamily.h"

#import <rocksdb/db.h>

@interface RocksDB (Private)
@property (nonatomic, assign) rocksdb::DB *db;
@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;
@property (nonatomic, retain) RocksDBOptions *options;
@property (nonatomic, retain) RocksDBReadOptions *readOptions;
@property (nonatomic, retain) RocksDBWriteOptions *writeOptions;
@end

@implementation RocksDBColumnFamily

- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
						andOptions:(RocksDBOptions *)options
{
	self = [super init];
	if (self) {
		self.db = db;
		self.columnFamily = columnFamily;
		self.options = options;
		[self setDefaultReadOptions:nil andWriteOptions:nil];
	}
	return self;
}

- (void)close
{
	@synchronized(self) {
		if (self.columnFamily != nullptr) {
			delete self.columnFamily;
			self.columnFamily = nullptr;
		}
	}
}

- (void)drop
{
	self.db->DropColumnFamily(self.columnFamily);
}

@end
