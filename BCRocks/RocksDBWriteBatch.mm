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

@end
