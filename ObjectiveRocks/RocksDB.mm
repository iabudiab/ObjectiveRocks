//
//  ObjectiveRocks.m
//  ObjectiveRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"

#import "RocksDBColumnFamily.h"
#import "RocksDBColumnFamily+Private.h"
#import "RocksDBColumnFamilyMetaData+Private.h"

#import "RocksDBOptions.h"
#import "RocksDBReadOptions.h"
#import "RocksDBWriteOptions.h"

#import "RocksDBIterator+Private.h"
#import "RocksDBWriteBatch+Private.h"

#import "RocksDBSnapshot.h"
#import "RocksDBSnapshot+Private.h"

#import "RocksDBError.h"
#import "RocksDBSlice.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

#import "RocksDBProperties.h"

#pragma mark - 

@interface RocksDBColumnFamilyDescriptor (Private)
@property (nonatomic, assign) std::vector<rocksdb::ColumnFamilyDescriptor> *columnFamilies;
@end

@interface RocksDBOptions (Private)
@property (nonatomic, assign) rocksdb::Options options;
@property (nonatomic, strong) RocksDBDatabaseOptions *databaseOptions;
@property (nonatomic, strong) RocksDBColumnFamilyOptions *columnFamilyOption;
@end

@interface RocksDBDatabaseOptions (Private)
@property (nonatomic, assign) rocksdb::DBOptions options;
@end

@interface RocksDBColumnFamilyOptions (Private)
@property (nonatomic, assign) rocksdb::ColumnFamilyOptions options;
@end

@interface RocksDBReadOptions (Private)
@property (nonatomic, assign) rocksdb::ReadOptions options;
@end

@interface RocksDBWriteOptions (Private)
@property (nonatomic, assign) rocksdb::WriteOptions options;
@end

@interface RocksDB ()
{
	NSString *_path;
	rocksdb::DB *_db;
	rocksdb::ColumnFamilyHandle *_columnFamily;
	std::vector<rocksdb::ColumnFamilyHandle *> *_columnFamilyHandles;

	NSMutableArray *_columnFamilies;

	RocksDBOptions *_options;
	RocksDBReadOptions *_readOptions;
	RocksDBWriteOptions *_writeOptions;
}
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) rocksdb::DB *db;
@property (nonatomic, assign) rocksdb::ColumnFamilyHandle *columnFamily;
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, strong) RocksDBReadOptions *readOptions;
@property (nonatomic, strong) RocksDBWriteOptions *writeOptions;
@end

@implementation RocksDB
@synthesize path = _path;
@synthesize db = _db;
@synthesize columnFamily = _columnFamily;
@synthesize options = _options;
@synthesize readOptions = _readOptions;
@synthesize writeOptions = _writeOptions;

#pragma mark - Lifecycle

+ (instancetype)databaseAtPath:(NSString *)path andDBOptions:(void (^)(RocksDBOptions *))optionsBlock
{
	RocksDB *rocks = [[RocksDB alloc] initWithPath:path];

	if (optionsBlock) {
		optionsBlock(rocks.options);
	}

	if ([rocks openDatabaseReadOnly:NO] == NO) {
		return nil;
	}
	return rocks;
}

+ (instancetype)databaseAtPath:(NSString *)path
			  columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
		  andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))optionsBlock
{
	RocksDB *rocks = [[RocksDB alloc] initWithPath:path];

	RocksDBDatabaseOptions *dbOptions = [RocksDBDatabaseOptions new];
	if (optionsBlock) {
		optionsBlock(dbOptions);
	}
	rocks.options.databaseOptions = dbOptions;

	if ([rocks openColumnFamilies:descriptor readOnly:NO] == NO) {
		return nil;
	}
	return rocks;
}

#ifndef ROCKSDB_LITE

+ (instancetype)databaseForReadOnlyAtPath:(NSString *)path
							 andDBOptions:(void (^)(RocksDBOptions *options))optionsBlock
{
	RocksDB *rocks = [[RocksDB alloc] initWithPath:path];

	if (optionsBlock) {
		optionsBlock(rocks.options);
	}

	if ([rocks openDatabaseReadOnly:YES] == NO) {
		return nil;
	}
	return rocks;
}

+ (instancetype)databaseForReadOnlyAtPath:(NSString *)path
						 columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
					 andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))optionsBlock
{
	RocksDB *rocks = [[RocksDB alloc] initWithPath:path];

	RocksDBDatabaseOptions *dbOptions = [RocksDBDatabaseOptions new];
	if (optionsBlock) {
		optionsBlock(dbOptions);
	}
	rocks.options.databaseOptions = dbOptions;

	if ([rocks openColumnFamilies:descriptor readOnly:YES] == NO) {
		return nil;
	}
	return rocks;
}

#endif

- (instancetype)initWithPath:(NSString *)path
{
	self = [super init];
	if (self) {
		_path = [path copy];
		_options = [RocksDBOptions new];
		_readOptions = [RocksDBReadOptions new];
		_writeOptions = [RocksDBWriteOptions new];
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
		[_columnFamilies makeObjectsPerformSelector:@selector(close)];

		if (_columnFamilyHandles != nullptr) {
			delete _columnFamilyHandles;
			_columnFamilyHandles = nullptr;
		}

		if (_db != nullptr) {
			delete _db;
			_db = nullptr;
		}
	}
}

#pragma mark - Open

- (BOOL)openDatabaseReadOnly:(BOOL)readOnly
{
	rocksdb::Status status;
	if (readOnly) {
		status = rocksdb::DB::OpenForReadOnly(_options.options, _path.UTF8String, &_db);
	} else {
		status = rocksdb::DB::Open(_options.options, _path.UTF8String, &_db);
	}

	if (!status.ok()) {
		NSLog(@"Error opening database: %@", [RocksDBError errorWithRocksStatus:status]);
		[self close];
		return NO;
	}
	_columnFamily = _db->DefaultColumnFamily();

	return YES;
}

- (BOOL)openColumnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor readOnly:(BOOL)readOnly
{
	rocksdb::Status status;
	std::vector<rocksdb::ColumnFamilyDescriptor> *columnFamilies = descriptor.columnFamilies;
	_columnFamilyHandles = new std::vector<rocksdb::ColumnFamilyHandle *>;

	if (readOnly) {
		status = rocksdb::DB::OpenForReadOnly(_options.options,
											  _path.UTF8String,
											  *columnFamilies,
											  _columnFamilyHandles,
											  &_db);
	} else {
		status = rocksdb::DB::Open(_options.options,
								   _path.UTF8String,
								   *columnFamilies,
								   _columnFamilyHandles,
								   &_db);
	}


	if (!status.ok()) {
		NSLog(@"Error opening database: %@", [RocksDBError errorWithRocksStatus:status]);
		[self close];
		return NO;
	}
	_columnFamily = _db->DefaultColumnFamily();

	return YES;
}

#pragma mark - Column Families

+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path
{
	std::vector<std::string> names;

	rocksdb::Status status = rocksdb::DB::ListColumnFamilies(rocksdb::Options(), path.UTF8String, &names);
	if (!status.ok()) {
		NSLog(@"Error listing column families in database at %@: %@", path, [RocksDBError errorWithRocksStatus:status]);
	}

	NSMutableArray *columnFamilies = [NSMutableArray array];
	for(auto it = std::begin(names); it != std::end(names); ++it) {
		[columnFamilies addObject:[[NSString alloc] initWithCString:it->c_str() encoding:NSUTF8StringEncoding]];
	}
	return columnFamilies;
}

- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name andOptions:(void (^)(RocksDBColumnFamilyOptions *options))optionsBlock
{
	RocksDBColumnFamilyOptions *columnFamilyOptions = [RocksDBColumnFamilyOptions new];
	if (optionsBlock) {
		optionsBlock(columnFamilyOptions);
	}

	rocksdb::ColumnFamilyHandle *handle;
	rocksdb::Status status = _db->CreateColumnFamily(columnFamilyOptions.options, name.UTF8String, &handle);
	if (!status.ok()) {
		NSLog(@"Error creating column family: %@", [RocksDBError errorWithRocksStatus:status]);
		return nil;
	}

	RocksDBOptions *options = [[RocksDBOptions alloc] initWithDatabaseOptions:_options.databaseOptions
													   andColumnFamilyOptions:columnFamilyOptions];
	
	RocksDBColumnFamily *columnFamily = [[RocksDBColumnFamily alloc] initWithDBInstance:_db
																		   columnFamily:handle
																			 andOptions:options];
	return columnFamily;
}

- (NSArray *)columnFamilies
{
	if (_columnFamilyHandles == nullptr) {
		return nil;
	}

	if (_columnFamilies == nil) {
		_columnFamilies = [NSMutableArray new];
		for(auto it = std::begin(*_columnFamilyHandles); it != std::end(*_columnFamilyHandles); ++it) {
			RocksDBColumnFamily *columnFamily = [[RocksDBColumnFamily alloc] initWithDBInstance:_db
																				   columnFamily:*it
																					 andOptions:_options];
			[_columnFamilies addObject:columnFamily];
		}
	}

	return _columnFamilies;
}

#ifndef ROCKSDB_LITE

- (RocksDBColumnFamilyMetaData *)columnFamilyMetaData
{
	rocksdb::ColumnFamilyMetaData metadata;
	_db->GetColumnFamilyMetaData(_columnFamily, &metadata);

	RocksDBColumnFamilyMetaData *columnFamilyMetaData = [[RocksDBColumnFamilyMetaData alloc] initWithMetaData:metadata];
	return columnFamilyMetaData;
}

#endif

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

#ifndef ROCKSDB_LITE

#pragma mark - Peroperties

- (NSString *)valueForProperty:(RocksDBProperty)property
{
	std::string value;
	bool ok = _db->GetProperty(_columnFamily,
							   SliceFromData([ResolveProperty(property) dataUsingEncoding:NSUTF8StringEncoding]),
							   &value);
	if (!ok) {
		return nil;
	}

	NSData *data = DataFromSlice(rocksdb::Slice(value));
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (uint64_t)valueForIntProperty:(RocksDBIntProperty)property
{
	uint64_t value;
	bool ok = _db->GetIntProperty(_columnFamily,
								  SliceFromData([ResolveIntProperty(property) dataUsingEncoding:NSUTF8StringEncoding]),
								  &value);
	if (!ok) {
		return 0;
	}
	return value;
}

#endif

#pragma mark - Write Operations

- (BOOL)setObject:(id)anObject forKey:(id)aKey
{
	return [self setObject:anObject forKey:aKey error:nil];
}

- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError * __autoreleasing *)error
{
	return [self setObject:anObject forKey:aKey error:error writeOptions:nil];
}

- (BOOL)setObject:(id)anObject forKey:(id)aKey  writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self setObject:anObject forKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)setObject:(id)anObject
		   forKey:(id)aKey
		  error:(NSError * __autoreleasing *)error
   writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	NSError *locError = nil;
	NSData *keyData = EncodeKey(aKey, (RocksDBEncodingOptions *)_options, &locError);
	NSData *valueData = EncodeValue(aKey, anObject, (RocksDBEncodingOptions *)_options, &locError);
	if (locError) {
		if (error && *error == nil) {
			*error = locError;
		}
		return NO;
	}

	return [self setData:valueData
				  forKey:keyData
				   error:error
			writeOptions:writeOptionsBlock];
}

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
									  _columnFamily,
									  SliceFromData(aKey),
									  SliceFromData(data));

	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}

	return YES;
}

#pragma mark - Merge Operations

- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey
{
	return [self mergeOperation:aMerge forKey:aKey error:nil];
}

- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError **)error
{
	return [self mergeOperation:aMerge forKey:aKey error:error writeOptions:nil];
}

- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self mergeOperation:aMerge forKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	NSError *locError = nil;
	NSData *keyData = EncodeKey(aKey, (RocksDBEncodingOptions *)_options, &locError);
	if (locError) {
		if (error && *error == nil) {
			*error = locError;
		}
		return NO;
	}

	return [self mergeData:[aMerge dataUsingEncoding:NSUTF8StringEncoding]
					forKey:keyData
			  writeOptions:writeOptionsBlock];
}

- (BOOL)mergeObject:(id)anObject forKey:(id)aKey
{
	return [self mergeObject:anObject forKey:aKey error:nil];
}

- (BOOL)mergeObject:(id)anObject forKey:(id)aKey error:(NSError **)error
{
	return [self mergeObject:anObject forKey:aKey error:error writeOptions:nil];
}

- (BOOL)mergeObject:(id)anObject forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self mergeObject:anObject forKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)mergeObject:(id)anObject
			 forKey:(id)aKey
			  error:(NSError **)error
	   writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	NSError *locError = nil;
	NSData *keyData = EncodeKey(aKey, (RocksDBEncodingOptions *)_options, &locError);
	NSData *valueData = EncodeValue(aKey, anObject, (RocksDBEncodingOptions *)_options, &locError);
	if (locError) {
		if (error && *error == nil) {
			*error = locError;
		}
		return NO;
	}

	return [self mergeData:valueData
					forKey:keyData
					 error:error
			  writeOptions:writeOptionsBlock];
}

- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey
{
	return [self mergeData:data forKey:aKey error:nil];
}

- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error
{
	return [self mergeData:data forKey:aKey error:error writeOptions:nil];
}

- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self mergeData:data forKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)mergeData:(NSData *)data
		   forKey:(NSData *)aKey
			error:(NSError **)error
	 writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	RocksDBWriteOptions *writeOptions = [_writeOptions copy];
	if (writeOptionsBlock) {
		writeOptionsBlock(writeOptions);
	}

	rocksdb::Status status = _db->Merge(_writeOptions.options,
										_columnFamily,
										SliceFromData(aKey),
										SliceFromData(data));

	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}

	return YES;
}

#pragma mark - Read Operations

- (id)objectForKey:(id)aKey
{
	return [self objectForKey:aKey error:nil];
}

- (id)objectForKey:(id)aKey error:(NSError **)error
{
	return [self objectForKey:aKey error:error readOptions:nil];
}

- (id)objectForKey:(id)aKey readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	return [self objectForKey:aKey error:nil readOptions:readOptionsBlock];
}

- (id)objectForKey:(id)aKey error:(NSError **)error readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptionsBlock
{
	NSError *locError = nil;
	NSData *keyData = EncodeKey(aKey, (RocksDBEncodingOptions *)_options, &locError);
	if (locError) {
		if (error && *error == nil) {
			*error = locError;
		}
		return nil;
	}

	NSData *data = [self dataForKey:keyData
							  error:error
						readOptions:readOptionsBlock];

	return DecodeValueData(aKey, data, (RocksDBEncodingOptions *)_options, error);
}

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
									  _columnFamily,
									  SliceFromData(aKey),
									  &value);
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return nil;
	}

	return DataFromSlice(rocksdb::Slice(value));
}

#pragma mark - Delete Operations

- (BOOL)deleteObjectForKey:(id)aKey
{
	return [self deleteObjectForKey:aKey error:nil];
}

- (BOOL)deleteObjectForKey:(id)aKey error:(NSError **)error
{
	return [self deleteObjectForKey:aKey error:error writeOptions:nil];
}

- (BOOL)deleteObjectForKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	return [self deleteObjectForKey:aKey error:nil writeOptions:writeOptionsBlock];
}

- (BOOL)deleteObjectForKey:(id)aKey
					 error:(NSError **)error
			  writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock
{
	NSError *locError = nil;
	NSData *keyData = EncodeKey(aKey, (RocksDBEncodingOptions *)_options, &locError);
	if (locError) {
		if (error && *error == nil) {
			*error = locError;
		}
		return NO;
	}

	return [self deleteDataForKey:keyData
							error:error
					 writeOptions:writeOptionsBlock];
}

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
										 _columnFamily,
										 SliceFromData(aKey));
	
	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
		}
		return NO;
	}

	return YES;
}

#pragma mark - Batch Writes

- (RocksDBWriteBatch *)writeBatch
{
	return [[RocksDBWriteBatch alloc] initWithColumnFamily:_columnFamily andEncodingOptions:(RocksDBEncodingOptions *)_options];
}

- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batchBlock
{
	return [self performWriteBatch:batchBlock error:nil];
}

- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batchBlock error:(NSError **)error
{
	if (batchBlock == nil) return NO;

	RocksDBWriteBatch *writeBatch = [self writeBatch];
	RocksDBWriteOptions *writeOptions = [_writeOptions copy];

	batchBlock(writeBatch, writeOptions);
	rocksdb::WriteBatch *batch = writeBatch.writeBatchBase->GetWriteBatch();
	rocksdb::Status status = _db->Write(writeOptions.options, batch);

	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
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

	rocksdb::WriteBatch *batch = writeBatch.writeBatchBase->GetWriteBatch();
	rocksdb::Status status = _db->Write(writeOptions.options, batch);

	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
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
	rocksdb::Iterator *iterator = _db->NewIterator(readOptions.options,
												   _columnFamily);

	return [[RocksDBIterator alloc] initWithDBIterator:iterator andEncodingOptions:(RocksDBEncodingOptions *)_options];
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

	RocksDBSnapshot *snapshot = [[RocksDBSnapshot alloc] initWithDBInstance:_db columnFamily:_columnFamily andReadOptions:readOptions];
	return snapshot;
}

@end
