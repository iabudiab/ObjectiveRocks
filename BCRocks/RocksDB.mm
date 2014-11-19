//
//  BCRocks.m
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"
#import "BCRocksError.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

@interface RocksDB ()
{
	rocksdb::DB *_db;
}
@end

@implementation RocksDB

#pragma mark - Lifecycle

- (instancetype)initWithPath:(NSString *)path
{
	self = [super init];
	if (self) {
		rocksdb::Options options;
		rocksdb::Status status = rocksdb::DB::Open(options, path.UTF8String, &_db);
		if (!status.ok()) {
			NSLog(@"Error creating database: %@", [BCRocksError errorWithRocksStatus:status]);
			[self close];
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[self close];
}

- (void)close
{
	@synchronized(self) {
		if (_db != NULL) {
			delete _db;
			_db = NULL;
		}
	}
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey
{
	rocksdb::Status status = _db->Put(rocksdb::WriteOptions(),
									  rocksdb::Slice((char *)aKey.bytes, aKey.length),
									  rocksdb::Slice((char *)data.bytes, data.length));
	return status.ok();
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error
{
	rocksdb::Status status = _db->Put(rocksdb::WriteOptions(),
									  rocksdb::Slice((char *)aKey.bytes, aKey.length),
									  rocksdb::Slice((char *)data.bytes, data.length));

	if (!status.ok()) {
		*error = [BCRocksError errorWithRocksStatus:status];
		return NO;
	}

	return YES;
}

@end
