//
//  RocksDBIndexedWriteBatch.m
//  ObjectiveRocks
//
//  Created by Iska on 20/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBIndexedWriteBatch.h"
#import "RocksDBWriteBatch+Private.h"

#import <rocksdb/utilities/write_batch_with_index.h>

@implementation RocksDBIndexedWriteBatch

- (instancetype)initColumnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					  andEncodingOptions:(RocksDBEncodingOptions *)options
{
	self = [super initWithNativeWriteBatch:new rocksdb::WriteBatchWithIndex()
							  columnFamily:columnFamily
						andEncodingOptions:options];
	return self;
}

@end
