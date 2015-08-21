//
//  RocksDBIndexedWriteBatch.m
//  ObjectiveRocks
//
//  Created by Iska on 20/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBIndexedWriteBatch.h"
#import "RocksDBWriteBatch+Private.h"
#import "RocksDBWriteBatchIterator+Private.h"

#import <rocksdb/utilities/write_batch_with_index.h>

@interface RocksDBIndexedWriteBatch ()
{
	rocksdb::WriteBatchWithIndex *_writeBatchWithIndex;
}
@end

@implementation RocksDBIndexedWriteBatch

#pragma mark - Lifecycle 

- (instancetype)initColumnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
			  andEncodingOptions:(RocksDBEncodingOptions *)options
{
	self = [super initWithNativeWriteBatch:new rocksdb::WriteBatchWithIndex()
							  columnFamily:columnFamily
						andEncodingOptions:options];
	if (self) {
		_writeBatchWithIndex = static_cast<rocksdb::WriteBatchWithIndex *>(self.writeBatchBase);
	}
	return self;
}

#pragma mark - Iterator

- (RocksDBWriteBatchIterator *)iterator
{
	rocksdb::WBWIIterator *nativeIterator = _writeBatchWithIndex->NewIterator(self.columnFamily);
	return [[RocksDBWriteBatchIterator alloc] initWithWriteBatchIterator:nativeIterator
													  andEncodingOptions:self.encodingOptions];
}

@end
