//
//  RocksDBSnapshot.h
//  ObjectiveRocks
//
//  Created by Iska on 06/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDB.h"
#import "RocksDBReadOptions.h"
#import "RocksDBSnapshotUnavailable.h"

namespace rocksdb {
	class DB;
	class ColumnFamilyHandle;
}

@interface RocksDBSnapshot : RocksDB

- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					andReadOptions:(RocksDBReadOptions *)readOptions;

@end

@interface RocksDBSnapshot (Unavailable)

- (instancetype)initWithPath:(NSString *)path NA("Create a snapshot via a DB instance");
- (instancetype)initWithPath:(NSString *)path
				andDBOptions:(void (^)(RocksDBOptions *options))options NA("Create a snapshot via a DB instance");

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Specify options when creating snapshot via DB instance");

- (RocksDBSnapshot *)snapshot NA("Yo Dawg, Snapshot in Snapshot ... ");
- (RocksDBSnapshot *)snapshotWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions  NA("Yo Dawg, Snapshot in Snapshot ... ");

#define NA_SELECTOR(sel) sel NA("Snapshot is read-only");
SNAPSHOT_PUT_MERGE_DELETE_SELECTORS
#undef NA_SELECTOR

@end
