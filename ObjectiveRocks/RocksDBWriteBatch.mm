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
	RocksDBOptions *_options;
	rocksdb::WriteBatch _writeBatch;
}
@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;
@end

@implementation RocksDBWriteBatch
@synthesize writeBatch = _writeBatch;

#pragma mark - Lifecycle

- (instancetype)initWithOptions:(RocksDBOptions *)options
{
	self = [super init];
	if (self) {
		_options = options;
	}
	return self;
}

#pragma mark - CRD

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if (_options.keyEncoder != nil && _options.valueEncoder != nil) {
		[self setData:_options.valueEncoder(aKey, anObject)
			   forKey:_options.keyEncoder(aKey)];
	}
}

- (void)setData:(NSData *)data forKey:(NSData *)aKey
{
	_writeBatch.Put(SliceFromData(aKey),
					SliceFromData(data));
}

- (void)deleteObjectForKey:(id)aKey
{
	if (_options.keyEncoder != nil) {
		[self deleteDataForKey:_options.keyEncoder(aKey)];
	}
}

- (void)deleteDataForKey:(NSData *)aKey
{
	_writeBatch.Delete(SliceFromData(aKey));
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
