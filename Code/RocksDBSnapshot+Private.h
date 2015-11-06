//
//  RocksDBSnapshot+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBSnapshot.h"

namespace rocksdb {
	class DB;
	class ColumnFamilyHandle;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBSnapshot (Private)

/**
 Initializes a new instance of `RocksDBWriteBatch` with the given options and
 rocksdb::DB abd rocksdb::ColumnFamilyHandle instances.

 @param db The rocks::DB instance.
 @param columnFamily The rocks::ColumnFamilyHandle instance.
 @param readOptions The read options.
 @return a newly-initialized instance of `RocksDBSnapshot`.

 @see RocksDBReadOptions
 */
- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					andReadOptions:(RocksDBReadOptions *)readOptions;

@end
