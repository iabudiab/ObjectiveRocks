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

@interface RocksDBWriteBatch (Private)

@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;

- (instancetype)initWithColumnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
				  andEncodingOptions:(RocksDBEncodingOptions *)options;

@end
