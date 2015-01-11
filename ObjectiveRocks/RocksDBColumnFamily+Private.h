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

@interface RocksDBColumnFamily (Private)

@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;

- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
						andOptions:(RocksDBOptions *)options;

@end
