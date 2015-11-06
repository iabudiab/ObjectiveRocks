//
//  RocksDBWriteBatch.m
//  ObjectiveRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatch.h"
#import "RocksDBWriteBatch+Private.h"
#import "RocksDBColumnFamily.h"
#import "RocksDBColumnFamily+Private.h"
#import "RocksDBSlice.h"

#import <rocksdb/write_batch_base.h>
#import <rocksdb/write_batch.h>

@interface RocksDBWriteBatch ()
{
	rocksdb::ColumnFamilyHandle *_columnFamily;
	RocksDBEncodingOptions *_encodingOptions;
}
@property (nonatomic, assign) rocksdb::WriteBatchBase *writeBatchBase;
@end

@implementation RocksDBWriteBatch
@synthesize writeBatchBase = _writeBatchBase;

#pragma mark - Lifecycle

- (instancetype)initWithColumnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					  andEncodingOptions:(RocksDBEncodingOptions *)encodingOptions
{
	return [self initWithNativeWriteBatch:new rocksdb::WriteBatch()
							 columnFamily:columnFamily
					   andEncodingOptions:encodingOptions];
}

- (instancetype)initWithNativeWriteBatch:(rocksdb::WriteBatchBase *)writeBatchBase
							columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
					  andEncodingOptions:(RocksDBEncodingOptions *)encodingOptions
{
	self = [super init];
	if (self) {
		_writeBatchBase = writeBatchBase;
		_columnFamily = columnFamily;
		_encodingOptions = encodingOptions;
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_writeBatchBase != nullptr) {
			delete _writeBatchBase;
			_writeBatchBase = nullptr;
		}
	}
}

#pragma mark - Put

- (void)setObject:(id)anObject forKey:(id)aKey
{
	[self setObject:anObject forKey:aKey inColumnFamily:nil];
}

- (void)setData:(NSData *)data forKey:(NSData *)aKey
{
	[self setData:data forKey:aKey inColumnFamily:nil];
}

- (void)setObject:(id)anObject forKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily
{
	[self setData:EncodeValue(aKey, anObject, _encodingOptions, nil)
		   forKey:EncodeKey(aKey, _encodingOptions, nil)
   inColumnFamily:columnFamily];
}

- (void)setData:(NSData *)data forKey:(NSData *)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily
{
	if (aKey != nil && data != nil) {
		rocksdb::ColumnFamilyHandle *handle = _columnFamily;
		if (columnFamily != nil) {
			handle = columnFamily.columnFamily;
		}

		_writeBatchBase->Put(handle,
							 SliceFromData(aKey),
							 SliceFromData(data));
	}
}

#pragma mark - Merge

- (void)mergeOperation:(NSString *)aMerge forKey:(id)aKey
{
	[self mergeOperation:aMerge forKey:aKey inColumnFamily:nil];
}

- (void)mergeObject:(id)anObject forKey:(id)aKey
{
	[self mergeObject:anObject forKey:aKey inColumnFamily:nil];
}

- (void)mergeData:(NSData *)data forKey:(NSData *)aKey
{
	[self mergeData:data forKey:aKey inColumnFamily:nil];
}

- (void)mergeOperation:(NSString *)aMerge forKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily
{
	[self mergeData:[aMerge dataUsingEncoding:NSUTF8StringEncoding]
			 forKey:EncodeKey(aKey, _encodingOptions, nil)
	 inColumnFamily:columnFamily];
}

- (void)mergeObject:(id)anObject forKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily
{
	[self mergeData:EncodeValue(aKey, anObject, _encodingOptions, nil)
			 forKey:EncodeKey(aKey, _encodingOptions, nil)
	 inColumnFamily:columnFamily];
}

- (void)mergeData:(NSData *)data forKey:(NSData *)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;
{
	if (aKey != nil && data != nil) {
		rocksdb::ColumnFamilyHandle *handle = _columnFamily;
		if (columnFamily != nil) {
			handle = columnFamily.columnFamily;
		}

		_writeBatchBase->Merge(handle,
							   SliceFromData(aKey),
							   SliceFromData(data));
	}
}

#pragma mark - Delete

- (void)deleteObjectForKey:(id)aKey
{
	[self deleteObjectForKey:aKey inColumnFamily:nil];
}

- (void)deleteDataForKey:(NSData *)aKey
{
	[self deleteDataForKey:aKey inColumnFamily:nil];
}

- (void)deleteObjectForKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily
{
	[self deleteDataForKey:EncodeKey(aKey, _encodingOptions, nil)
			inColumnFamily:columnFamily];
}

- (void)deleteDataForKey:(NSData *)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily
{
	if (aKey != nil) {
		rocksdb::ColumnFamilyHandle *handle = _columnFamily;
		if (columnFamily != nil) {
			handle = columnFamily.columnFamily;
		}

		_writeBatchBase->Delete(handle,
								SliceFromData(aKey));
	}
}

#pragma mark - 

- (void)putLogData:(NSData *)logData;
{
	if (logData != nil) {
		_writeBatchBase->PutLogData(SliceFromData(logData));
	}
}

- (void)clear
{
	_writeBatchBase->Clear();
}

#pragma mark - Meta

- (int)count
{
	return _writeBatchBase->GetWriteBatch()->Count();
}

- (NSData *)data
{
	std::string rep = _writeBatchBase->GetWriteBatch()->Data();
	return DataFromSlice(rocksdb::Slice(rep));
}

- (size_t)dataSize
{
	return _writeBatchBase->GetWriteBatch()->GetDataSize();
}

@end
