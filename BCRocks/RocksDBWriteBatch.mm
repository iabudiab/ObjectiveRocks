//
//  RocksDBWriteBatch.m
//  BCRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatch.h"

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
	_writeBatch.Put(rocksdb::Slice((char *)aKey.bytes, aKey.length),
					rocksdb::Slice((char *)data.bytes, data.length));
	
}

- (void)deleteDataForKey:(NSData *)aKey
{
	_writeBatch.Delete(rocksdb::Slice((char *)aKey.bytes, aKey.length));
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
	NSData *data = [[NSData alloc] initWithBytes:rep.data() length:rep.size()];
	return data;
}

- (size_t)dataSize
{
	return _writeBatch.GetDataSize();
}

@end
