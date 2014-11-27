//
//  BCRocks.m
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"
#import "BCRocksError.h"
#import "RocksDBOptions.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

#pragma mark - 

@interface RocksDBOptions (Private)
@property (nonatomic, readonly) rocksdb::Options options;
@end

@interface RocksDB ()
{
	rocksdb::DB *_db;
	RocksDBOptions *_options;
}
@end

@implementation RocksDB

#pragma mark - Lifecycle

- (instancetype)initWithPath:(NSString *)path
{
	return [self initWithPath:path andOptions:nil];
}

- (instancetype)initWithPath:(NSString *)path andOptions:(void (^)(RocksDBOptions *))optionsBlock
{
	self = [super init];
	if (self) {
		_options = [RocksDBOptions new];
		if (optionsBlock) {
			optionsBlock(_options);
		}

		rocksdb::Status status = rocksdb::DB::Open(_options.options, path.UTF8String, &_db);
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
	return [self setData:data forKey:aKey error:nil];
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

- (NSData *)dataForKey:(NSData *)aKey
{
	return [self dataForKey:aKey error:nil];
}

- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error
{
	std::string value;
	rocksdb::Status status = _db->Get(rocksdb::ReadOptions(),
									  rocksdb::Slice((char *)aKey.bytes, aKey.length),
									  &value);
	if (!status.ok()) {
		*error = [BCRocksError errorWithRocksStatus:status];
		return nil;
	}
	return [NSData dataWithBytes:value.c_str() length:value.length()];
}

@end
