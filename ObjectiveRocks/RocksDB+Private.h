//
//  RocksDB+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDB.h"

namespace rocksdb {
	class DB;
	class ColumnFamilyHandle;
}

@interface RocksDB (Private)

@property (nonatomic, assign) rocksdb::DB *db;
@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;
@property (nonatomic, retain) RocksDBOptions *options;
@property (nonatomic, retain) RocksDBReadOptions *readOptions;
@property (nonatomic, retain) RocksDBWriteOptions *writeOptions;

@end
