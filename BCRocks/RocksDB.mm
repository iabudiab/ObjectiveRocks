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

@interface RocksDBWriteBatch (Private)
@property (nonatomic, readonly) rocksdb::WriteBatch writeBatch;
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

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError * __autoreleasing *)error
{
	return [self setData:data forKey:aKey error:error writeOptions:nil];
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self setData:data forKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey
		  error:(NSError * __autoreleasing *)error
   writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
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
		NSError *temp = [BCRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}

	return YES;
}

#pragma mark - Read Operations

- (NSData *)dataForKey:(NSData *)aKey
{
	return [self dataForKey:aKey error:nil];
}

- (NSData *)dataForKey:(NSData *)aKey error:(NSError * __autoreleasing *)error
{
	return [self dataForKey:aKey error:error readOptions:nil];
}

- (NSData *)dataForKey:(NSData *)aKey readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	return [self dataForKey:aKey error:nil readOptions:readOptionsBlock];
}

- (NSData *)dataForKey:(NSData *)aKey
				 error:(NSError * __autoreleasing *)error
		   readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
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
		NSError *temp = [BCRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return nil;
	}

	return [NSData dataWithBytes:value.c_str() length:value.length()];
}

#pragma mark - Delete Operations

- (BOOL)deleteDataForKey:(NSData *)aKey
{
	return [self deleteDataForKey:aKey error:nil];
}

- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError * __autoreleasing *)error
{
	return [self deleteDataForKey:aKey error:error writeOptions:nil];
}

- (BOOL)deleteDataForKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self deleteDataForKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)deleteDataForKey:(NSData *)aKey
				   error:(NSError **)error
			writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	RocksDBWriteOptions *writeOptions = _writeOptions;
	if (writeOptionsBlock) {
		writeOptions = [RocksDBWriteOptions new];
		writeOptionsBlock(writeOptions);
	}

	rocksdb::Status status = _db->Delete(writeOptions.options,
									  rocksdb::Slice((char *)aKey.bytes, aKey.length));
	
	if (!status.ok()) {
		NSError *temp = [BCRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}

	return YES;
}

#pragma mark - Batch Writes


- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batchBlock
{
	RocksDBWriteBatch *writeBatch = [RocksDBWriteBatch new];
	RocksDBWriteOptions *writeOptions = [RocksDBWriteOptions new];
	if (batchBlock) {
		batchBlock(writeBatch, writeOptions);
		rocksdb::WriteBatch batch = writeBatch.writeBatch;
		rocksdb::Status status = _db->Write(writeOptions.options, &batch);
		if (!status.ok()) {
			return NO;
		}
		return YES;
	}
	return NO;
}

@end
