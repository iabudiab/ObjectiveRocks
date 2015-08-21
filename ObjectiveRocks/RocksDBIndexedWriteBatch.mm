//
//  RocksDBIndexedWriteBatch.m
//  ObjectiveRocks
//
//  Created by Iska on 20/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBIndexedWriteBatch.h"

#import "RocksDB+Private.h"
#import "RocksDBOptions+Private.h"
#import "RocksDBWriteBatch+Private.h"
#import "RocksDBWriteBatchIterator+Private.h"
#import "RocksDBColumnFamily+Private.h"

#import "RocksDBSlice.h"

#import <rocksdb/db.h>
#import <rocksdb/options.h>
#import <rocksdb/utilities/write_batch_with_index.h>

@interface RocksDBIndexedWriteBatch ()
{
	rocksdb::WriteBatchWithIndex *_writeBatchWithIndex;
	RocksDB *database;
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

#pragma mark - Queries

- (id)objectForKey:(id)aKey
	inColumnFamily:(RocksDBColumnFamily *)columnFamily
			 error:(NSError * __autoreleasing *)error
{
	rocksdb::ColumnFamilyHandle *columnFamilyHandle = columnFamily != nil ? columnFamily.columnFamily : nullptr;

	std::string value;
	rocksdb::Status status = _writeBatchWithIndex->GetFromBatch(columnFamilyHandle,
																database.db->GetDBOptions(),
																SliceFromKey(aKey, self.encodingOptions, nil),
																&value);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return nil;
	}

	return DecodeValueSlice(aKey, rocksdb::Slice(value), self.encodingOptions, error);
}

- (id)objectForKeyIncludingDatabase:(id)aKey
					 inColumnFamily:(RocksDBColumnFamily *)columnFamily
							  error:(NSError * __autoreleasing *)error
						readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	RocksDBReadOptions *readOptions = [database.readOptions copy];
	if (readOptionsBlock) {
		readOptionsBlock(readOptions);
	}

	rocksdb::ColumnFamilyHandle *columnFamilyHandle = columnFamily != nil ? columnFamily.columnFamily : nullptr;

	std::string value;
	rocksdb::Status status = _writeBatchWithIndex->GetFromBatchAndDB(database.db,
																	 readOptions.options,
																	 columnFamilyHandle,
																	 SliceFromKey(aKey, self.encodingOptions, nil),
																	 &value);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return nil;
	}

	return DecodeValueSlice(aKey, rocksdb::Slice(value), self.encodingOptions, error);
}

#pragma mark - Iterator

- (RocksDBWriteBatchIterator *)iterator
{
	rocksdb::WBWIIterator *nativeIterator = _writeBatchWithIndex->NewIterator(self.columnFamily);
	return [[RocksDBWriteBatchIterator alloc] initWithWriteBatchIterator:nativeIterator
													  andEncodingOptions:self.encodingOptions];
}

@end
