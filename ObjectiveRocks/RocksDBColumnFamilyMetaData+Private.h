//
//  RocksDBColumnFamilyMetaData+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyMetaData.h"

namespace rocksdb {
	class ColumnFamilyMetaData;
	class LevelMetaData;
	class SstFileMetaData;
}

@interface RocksDBColumnFamilyMetaData (Private)

- (instancetype)initWithMetaData:(rocksdb::ColumnFamilyMetaData)metadata;

@end

@interface RocksDBLevelFileMetaData (Private)

- (instancetype)initWithLevelMetaData:(rocksdb::LevelMetaData)metadata;

@end

@interface RocksDBSstFileMetaData (Private)

- (instancetype)initWithSstFileMetaData:(rocksdb::SstFileMetaData)metadata;

@end
