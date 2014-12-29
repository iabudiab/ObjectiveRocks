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
	}
	return self;
}

- (void)dealloc
{
	[self close];
}

- (void)close
{
	@synchronized(self) {
		if (self.columnFamily != NULL) {
			delete self.columnFamily;
			self.columnFamily = NULL;
		}
	}
}

- (void)drop
{
	self.db->DropColumnFamily(self.columnFamily);
}

@end
