//
//  RocksDBWriteBatch.m
//  ObjectiveRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatch.h"
#import "RocksDBSlice.h"

#import <rocksdb/write_batch.h>

@interface RocksDBWriteBatch ()
{
	RocksDBEncodingOptions *_encodingOptions;
	rocksdb::WriteBatch _writeBatch;
}
@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;
@end

@implementation RocksDBWriteBatch
@synthesize writeBatch = _writeBatch;

#pragma mark - Lifecycle

- (instancetype)initWithOptions:(RocksDBEncodingOptions *)options
{
	self = [super init];
	if (self) {
		_encodingOptions = options;
	}
	return self;
}

#pragma mark - CRUD

- (void)setObject:(id)anObject forKey:(id)aKey
{
	[self setData:EncodeValue(aKey, anObject, _encodingOptions, nil)
		   forKey:EncodeKey(aKey, _encodingOptions, nil)];
}

- (void)setData:(NSData *)data forKey:(NSData *)aKey
{
	if (aKey != nil && data != nil) {
		_writeBatch.Put(SliceFromData(aKey),
						SliceFromData(data));
	}
}

- (void)mergeOperation:(NSString *)aMerge forKey:(id)aKey
{
	[self mergeData:[aMerge dataUsingEncoding:NSUTF8StringEncoding]
			 forKey:EncodeKey(aKey, _encodingOptions, nil)];
}

- (void)mergeObject:(id)anObject forKey:(id)aKey
{
	[self mergeData:EncodeValue(aKey, anObject, _encodingOptions, nil)
			 forKey:EncodeKey(aKey, _encodingOptions, nil)];
}

- (void)mergeData:(NSData *)data forKey:(NSData *)aKey
{
	if (aKey != nil && data != nil) {
		_writeBatch.Merge(SliceFromData(aKey),
						  SliceFromData(data));
	}

}

- (void)deleteObjectForKey:(id)aKey
{
	[self deleteDataForKey:EncodeKey(aKey, _encodingOptions, nil)];
}

- (void)deleteDataForKey:(NSData *)aKey
{
	if (aKey != nil) {
		_writeBatch.Delete(SliceFromData(aKey));
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
