//
//  RocksDBWriteBatch.m
//  ObjectiveRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatch.h"
#import "RocksDBColumnFamily.h"
#import "RocksDBSlice.h"

#import <rocksdb/write_batch.h>

@interface RocksDBColumnFamily (Private)
@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;
@end

@interface RocksDBWriteBatch ()
{
	RocksDBEncodingOptions *_encodingOptions;
	rocksdb::WriteBatch _writeBatch;
	rocksdb::ColumnFamilyHandle *_columnFamily;
}
@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;
@end

@implementation RocksDBWriteBatch
@synthesize writeBatch = _writeBatch;

#pragma mark - Lifecycle

- (instancetype)initWithColumnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
				  andEncodingOptions:(RocksDBEncodingOptions *)options
{
	self = [super init];
	if (self) {
		_columnFamily = columnFamily;
		_encodingOptions = options;
	}
	return self;
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

		_writeBatch.Put(handle,
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
		_writeBatch.Merge(handle,
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
		_writeBatch.Delete(handle,
						   SliceFromData(aKey));
	}
}

#pragma mark - 

- (void)putLogData:(NSData *)logData;
{
	if (logData != nil) {
		_writeBatch.PutLogData(SliceFromData(logData));
	}
}

- (void)clear
{
	_writeBatch.Clear();
}

#pragma mark - Meta

- (int)count
{
	return _writeBatch.Count();
}

- (NSData *)data
{
	std::string rep = _writeBatch.Data();
	return DataFromSlice(rocksdb::Slice(rep));
}

- (size_t)dataSize
{
	return _writeBatch.GetDataSize();
}

@end
