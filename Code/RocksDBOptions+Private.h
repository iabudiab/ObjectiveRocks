//
//  RocksDBOptions+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 21/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBOptions.h"

@class RocksDBDatabaseOptions;
@class RocksDBColumnFamilyOptions;

namespace rocksdb
{
	class Options;
	class DBOptions;
	class ColumnFamilyOptions;
	class ReadOptions;
	class WriteOptions;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBOptions (Private)
@property (nonatomic, assign) rocksdb::Options options;
@property (nonatomic, strong) RocksDBDatabaseOptions *databaseOptions;
@property (nonatomic, strong) RocksDBColumnFamilyOptions *columnFamilyOption;
@end

@interface RocksDBDatabaseOptions (Private)
@property (nonatomic, assign) const rocksdb::DBOptions options;
@end

@interface RocksDBColumnFamilyOptions (Private)
@property (nonatomic, assign) rocksdb::ColumnFamilyOptions options;
@end

@interface RocksDBReadOptions (Private)
@property (nonatomic, assign) rocksdb::ReadOptions options;
@end

@interface RocksDBWriteOptions (Private)
@property (nonatomic, assign) rocksdb::WriteOptions options;
@end
