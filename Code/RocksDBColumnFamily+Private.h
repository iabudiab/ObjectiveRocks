//
//  RocksDBColumnFamily+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamily.h"

namespace rocksdb {
	class DB;
	class ColumnFamilyHandle;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBColumnFamily (Private)

/** @brief The underlying rocksdb::ColumnFamilyHandle associated with this instance. */
@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;

/**
 Initializes a new instance of `RocksDBColumnFamily` with the given options for 
 rocks::DB and rocks::ColumnFamilyHandle instances.
 
 @param db The rocks::DB instance.
 @param columnFamily The rocks::ColumnFamilyHandle instance.
 @param options The DB options.
 @return a newly-initialized instance of `RocksDBColumnFamily`.
 */
- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
						andOptions:(RocksDBOptions *)options;

@end
