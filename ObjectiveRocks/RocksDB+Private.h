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

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDB (Private)

/** @brief The underlying rocks::DB instance. */
@property (nonatomic, assign) rocksdb::DB *db;

/** @brief The underlying rocksdb::ColumnFamilyHandle associated with this instance. */
@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;

/** @brief The DB options. 
 @see RocksDBOptions
 */
@property (nonatomic, retain) RocksDBOptions *options;

/** @brief The read options.
 @see RocksDBReadOptions
 */
@property (nonatomic, retain) RocksDBReadOptions *readOptions;

/** @brief The write options
 @see RocksDBWriteOptions
 */
@property (nonatomic, retain) RocksDBWriteOptions *writeOptions;

@end
