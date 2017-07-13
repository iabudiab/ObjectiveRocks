//
//  RocksDBColumnFamilyMetaData+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyMetadata.h"

namespace rocksdb {
	class ColumnFamilyMetaData;
	class LevelMetaData;
	class SstFileMetaData;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBColumnFamilyMetaData (Private)

/**
 Initializes a new instance of `RocksDBColumnFamilyMetaData` with the given
 rocksdb::ColumnFamilyMetaData
 */
- (instancetype)initWithMetaData:(rocksdb::ColumnFamilyMetaData)metadata;

@end

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBLevelFileMetaData (Private)

/**
 Initializes a new instance of `RocksDBLevelFileMetaData` with the given
 rocksdb::LevelMetaData
 */
- (instancetype)initWithLevelMetaData:(rocksdb::LevelMetaData)metadata;

@end

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBSstFileMetaData (Private)

/**
 Initializes a new instance of `RocksDBSstFileMetaData` with the given
 rocksdb::SstFileMetaData
 */
- (instancetype)initWithSstFileMetaData:(rocksdb::SstFileMetaData)metadata;

@end
