//
//  RocksDBWriteBatch+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatch.h"

namespace rocksdb {
	class ColumnFamilyHandle;
	class WriteBatch;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBWriteBatch (Private)

/** @brief The rocksdb::WriteBatch associated with this instance. */
@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;

/**
 Initializes a new instance of `RocksDBWriteBatch` with the given options and
 rocksdb::ColumnFamilyHandle instance.

 @param columnFamily The rocks::ColumnFamilyHandle instance.
 @param options The Encoding options.
 @return a newly-initialized instance of `RocksDBWriteBatch`.

 @see RocksDBEncodingOptions
 */
- (instancetype)initWithColumnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
				  andEncodingOptions:(RocksDBEncodingOptions *)options;

@end
