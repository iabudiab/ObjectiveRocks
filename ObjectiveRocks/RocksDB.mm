//
//  ObjectiveRocks.m
//  ObjectiveRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"
#import "ObjectiveRocksError.h"
#import "RocksDBOptions.h"
#import "RocksDBReadOptions.h"
#import "RocksDBWriteOptions.h"
#import "RocksDBSnapshot.h"
#import "RocksDBSlice.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

#pragma mark - 

@interface RocksDBOptions (Private)
@property (nonatomic, assign) rocksdb::Options options;
@end

@interface RocksDBReadOptions (Private)
@property (nonatomic, assign) rocksdb::ReadOptions options;
@end

@interface RocksDBWriteOptions (Private)
@property (nonatomic, assign) rocksdb::WriteOptions options;
@end

@interface RocksDBWriteBatch (Private)
@property (nonatomic, assign) rocksdb::WriteBatch writeBatch;
@end

@interface RocksDB ()
{
	rocksdb::DB *_db;
	RocksDBOptions *_options;
	RocksDBReadOptions *_readOptions;
	RocksDBWriteOptions *_writeOptions;
}
@property (nonatomic, assign) rocksdb::DB *db;
@property (nonatomic, retain) RocksDBOptions *options;
@property (nonatomic, retain) RocksDBReadOptions *readOptions;
@property (nonatomic, retain) RocksDBWriteOptions *writeOptions;
@end

@implementation RocksDB
@synthesize db = _db;
@synthesize options = _options;
@synthesize readOptions = _readOptions;
@synthesize writeOptions = _writeOptions;

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
			NSLog(@"Error creating database: %@", [ObjectiveRocksError errorWithRocksStatus:status]);
			[self close];
			return nil;
		}
		[self setDefaultReadOptions:nil andWriteOptions:nil];
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
	RocksDBWriteOptions *writeOptions = [_writeOptions copy];
	if (writeOptionsBlock) {
		writeOptionsBlock(writeOptions);
	}

	rocksdb::Status status = _db->Put(writeOptions.options,
									  SliceFromData(aKey),
									  SliceFromData(data));

	if (!status.ok()) {
		NSError *temp = [ObjectiveRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}

	return YES;
}

#pragma mark - Merge Operations

- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey
{
	rocksdb::Status status = _db->Merge(_writeOptions.options,
										SliceFromData(aKey),
										SliceFromData(data));
	
	if (!status.ok()) {
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
	RocksDBReadOptions *readOptions = [_readOptions copy];
	if (readOptionsBlock) {
		readOptionsBlock(readOptions);
	}

	std::string value;
	rocksdb::Status status = _db->Get(readOptions.options,
									  SliceFromData(aKey),
									  &value);
	if (!status.ok()) {
		NSError *temp = [ObjectiveRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return nil;
	}

	return DataFromSlice(rocksdb::Slice(value));
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
	RocksDBWriteOptions *writeOptions = [_writeOptions copy];
	if (writeOptionsBlock) {
		writeOptionsBlock(writeOptions);
	}

	rocksdb::Status status = _db->Delete(writeOptions.options,
										 SliceFromData(aKey));
	
	if (!status.ok()) {
		NSError *temp = [ObjectiveRocksError errorWithRocksStatus:status];
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
	return [self performWriteBatch:batchBlock error:nil];
}

- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batchBlock error:(NSError **)error
{
	if (batchBlock == nil) return NO;

	RocksDBWriteBatch *writeBatch = [RocksDBWriteBatch new];
	RocksDBWriteOptions *writeOptions = [_writeOptions copy];

	batchBlock(writeBatch, writeOptions);
	rocksdb::WriteBatch batch = writeBatch.writeBatch;
	rocksdb::Status status = _db->Write(writeOptions.options, &batch);

	if (!status.ok()) {
		NSError *temp = [ObjectiveRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}
	return YES;
}

- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self applyWriteBatch:writeBatch error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	RocksDBWriteOptions *writeOptions = [_writeOptions copy];
	if (writeOptionsBlock) {
		writeOptionsBlock(writeOptions);
	}

	rocksdb::WriteBatch batch = writeBatch.writeBatch;
	rocksdb::Status status = _db->Write(writeOptions.options, &batch);

	if (!status.ok()) {
		NSError *temp = [ObjectiveRocksError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}
	return YES;
}

#pragma mark - Iteration

- (RocksDBIterator *)iterator
{
	return [self iteratorWithReadOptions:nil];
}

- (RocksDBIterator *)iteratorWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	RocksDBReadOptions *readOptions = [_readOptions copy];
	if (readOptionsBlock) {
		readOptionsBlock(readOptions);
	}
	rocksdb::Iterator *iterator = _db->NewIterator(readOptions.options);

	return [[RocksDBIterator alloc] initWithDBIterator:iterator];
}

#pragma mark - Snapshot

- (RocksDBSnapshot *)snapshot
{
	return [self snapshotWithReadOptions:nil];
}

- (RocksDBSnapshot *)snapshotWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	RocksDBReadOptions *readOptions = [_readOptions copy];
	if (readOptionsBlock) {
		readOptionsBlock(readOptions);
	}

	rocksdb::ReadOptions options = readOptions.options;
	options.snapshot = _db->GetSnapshot();
	readOptions.options = options;

	RocksDBSnapshot *snapshot = [[RocksDBSnapshot alloc] initWithDBInstance:_db andReadOptions:readOptions];
	return snapshot;
}

@end
