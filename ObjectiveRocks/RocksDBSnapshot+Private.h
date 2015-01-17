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

@interface RocksDBSnapshot (Private)

- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					andReadOptions:(RocksDBReadOptions *)readOptions;

@end
