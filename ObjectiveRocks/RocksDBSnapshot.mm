//
//  RocksDBSnapshot.m
//  ObjectiveRocks
//
//  Created by Iska on 06/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBSnapshot.h"

#import <rocksdb/db.h>

@interface RocksDB (Private)
@property (nonatomic, assign) rocksdb::DB *db;
@property (nonatomic, retain) RocksDBOptions *options;
@property (nonatomic, retain) RocksDBReadOptions *readOptions;
@property (nonatomic, retain) RocksDBWriteOptions *writeOptions;
@end

@interface RocksDBReadOptions (Private)
@property (nonatomic, assign) rocksdb::ReadOptions options;
@end

@implementation RocksDBSnapshot

- (instancetype)initWithDBInstance:(rocksdb::DB *)db andReadOptions:(RocksDBReadOptions *)readOptions
{
	self = [super init];
	if (self) {
		self.db = db;
		self.readOptions = readOptions;
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
		rocksdb::ReadOptions options = self.readOptions.options;
		if (options.snapshot != NULL) {
			self.db->ReleaseSnapshot(options.snapshot);
			options.snapshot = NULL;
			self.readOptions.options = options;
		}
	}
}


@end
