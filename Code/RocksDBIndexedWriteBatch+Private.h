//
//  RocksDBIndexedWriteBatch+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 12/06/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

namespace rocksdb {
	class DB;
	class ColumnFamilyHandle;
	class WriteBatchBase;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBIndexedWriteBatch (Private)

/**
 Initializes a new instance of a simple `RocksDBIndexedWriteBatch` with the given DB instance,
 rocksdb::ColumnFamilyHandle instance and encoding options.

 @param db The rocksdb::DB instance.
 @param columnFamily The rocks::ColumnFamilyHandle instance.
 @param readOptions The read options.
 @return a newly-initialized instance of `RocksDBIndexedWriteBatch`.
 */
- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					   readOptions:(RocksDBReadOptions *)readOptions;

@end
