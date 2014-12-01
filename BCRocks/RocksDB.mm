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
#import "RocksDBReadOptions.h"
#import "RocksDBWriteOptions.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

#pragma mark - 

@interface RocksDBOptions (Private)
@property (nonatomic, readonly) rocksdb::Options options;
@end

@interface RocksDBReadOptions (Private)
@property (nonatomic, readonly) rocksdb::ReadOptions options;
@end

@interface RocksDBWriteOptions (Private)
@property (nonatomic, readonly) rocksdb::WriteOptions options;
@end

@interface RocksDB ()
{
	rocksdb::DB *_db;
	RocksDBOptions *_options;
	RocksDBReadOptions *_readOptions;
	RocksDBWriteOptions *_writeOptions;
}
@end

@implementation RocksDB

#pragma mark - Lifecycle

- (instancetype)initWithPath:(NSString *)path
{
	return [self initWithPath:path andDBOptions:nil];
}

- (instancetype)initWithPath:(NSString *)path andDBOptions:(void (^)(RocksDBOptions *))optionsBlock
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

#pragma mark - Read/Write Options

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *))readOptionsBlock andWriteOptions:(void (^)(RocksDBWriteOptions *))writeOptionsBlock
{
	_readOptions = [RocksDBReadOptions new];
	_writeOptions = [RocksDBWriteOptions new];

	if (readOptionsBlock) {
		readOptionsBlock(_readOptions);
	}

	if (writeOptionsBlock) {
		writeOptionsBlock(_writeOptions);
	}
}

#pragma mark - Write Operations

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey
{
	return [self setData:data forKey:aKey error:nil];
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error
{
	return [self setData:data forKey:aKey error:error withWriteOptions:nil];
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self setData:data forKey:aKey error:nil withWriteOptions:writeOptionsBlock];
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	RocksDBWriteOptions *writeOptions = _writeOptions;
	if (writeOptionsBlock) {
		writeOptions = [RocksDBWriteOptions new];
		writeOptionsBlock(writeOptions);
	}

	rocksdb::Status status = _db->Put(writeOptions.options,
									  rocksdb::Slice((char *)aKey.bytes, aKey.length),
									  rocksdb::Slice((char *)data.bytes, data.length));

	if (!status.ok()) {
		*error = [BCRocksError errorWithRocksStatus:status];
		return NO;
	}

	return YES;
}

#pragma mark - Read Operations

- (NSData *)dataForKey:(NSData *)aKey
{
	return [self dataForKey:aKey error:nil];
}

- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error
{
	return [self dataForKey:aKey error:error withReadOptions:nil];
}

- (NSData *)dataForKey:(NSData *)aKey withReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	return [self dataForKey:aKey error:nil withReadOptions:readOptionsBlock];
}

- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error withReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	RocksDBReadOptions *readOptions = _readOptions;
	if (readOptionsBlock) {
		readOptions = [RocksDBReadOptions new];
		readOptionsBlock(readOptions);
	}

	std::string value;
	rocksdb::Status status = _db->Get(readOptions.options,
									  rocksdb::Slice((char *)aKey.bytes, aKey.length),
									  &value);
	if (!status.ok()) {
		*error = [BCRocksError errorWithRocksStatus:status];
		return nil;
	}

	return [NSData dataWithBytes:value.c_str() length:value.length()];
}

#pragma mark - Delete Operations

- (BOOL)deleteDataForKey:(NSData *)aKey
{
	return [self deleteDataForKey:aKey error:nil];
}

- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error
{
	return [self deleteDataForKey:aKey error:error withWriteOptions:nil];
}

- (BOOL)deleteDataForKey:(NSData *)aKey withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self deleteDataForKey:aKey error:nil withWriteOptions:writeOptionsBlock];
}

- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	RocksDBWriteOptions *writeOptions = _writeOptions;
	if (writeOptionsBlock) {
		writeOptions = [RocksDBWriteOptions new];
		writeOptionsBlock(writeOptions);
	}

	rocksdb::Status status = _db->Delete(writeOptions.options,
									  rocksdb::Slice((char *)aKey.bytes, aKey.length));
	
	if (!status.ok()) {
		*error = [BCRocksError errorWithRocksStatus:status];
		return NO;
	}

	return YES;
}

@end
