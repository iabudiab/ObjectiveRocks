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
	rocksdb::WriteBatch _writeBatch;
}
@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;
@end

@implementation RocksDBWriteBatch
@synthesize writeBatch = _writeBatch;

#pragma mark - CRD

- (void)setData:(NSData *)data forKey:(NSData *)aKey
{
	_writeBatch.Put(SliceFromData(aKey),
					SliceFromData(data));
	
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
