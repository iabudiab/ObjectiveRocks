//
//  ObjectiveRocks.h
//  ObjectiveRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBColumnFamilyDescriptor.h"
#import "RocksDBOptions.h"
#import "RocksDBReadOptions.h"
#import "RocksDBWriteOptions.h"
#import "RocksDBWriteBatch.h"
#import "RocksDBIterator.h"

@class RocksDBColumnFamily;
@class RocksDBSnapshot;

@interface RocksDB : NSObject

+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path;

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path
				andDBOptions:(void (^)(RocksDBOptions *options))options;
- (instancetype)initWithPath:(NSString *)path
			  columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
		  andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))options;

- (void)close;

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
										 andOptions:(void (^)(RocksDBColumnFamilyOptions *options))optionsBlock;
- (NSArray *)columnFamilies;

@end

@interface RocksDB (WriteOps)

- (BOOL)setObject:(id)anObject forKey:(id)aKey;
- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError **)error;
- (BOOL)setObject:(id)anObject forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock;
- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

@end

@interface RocksDB (MergeOps)

- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey;
- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError **)error;
- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)mergeObject:(id)anObject forKey:(id)aKey;
- (BOOL)mergeObject:(id)anObject forKey:(id)aKey error:(NSError **)error;
- (BOOL)mergeObject:(id)anObject forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)mergeObject:(id)anObject forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey;
- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error;
- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

@end

@interface RocksDB (ReadOps)

- (id)objectForKey:(id)aKey;
- (id)objectForKey:(id)aKey error:(NSError **)error;
- (id)objectForKey:(id)aKey readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;
- (id)objectForKey:(id)aKey error:(NSError **)error readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;

- (NSData *)dataForKey:(NSData *)aKey;
- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error;
- (NSData *)dataForKey:(NSData *)aKey readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;
- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;

@end

@interface RocksDB (DeleteOps)

- (BOOL)deleteObjectForKey:(id)aKey;
- (BOOL)deleteObjectForKey:(id)aKey error:(NSError **)error;
- (BOOL)deleteObjectForKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)deleteObjectForKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)deleteDataForKey:(NSData *)aKey;
- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error;
- (BOOL)deleteDataForKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

@end

@interface RocksDB (WriteBatch)

- (RocksDBWriteBatch *)writeBatch;
- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch;
- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError **)error;
- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

@end

@interface RocksDB (Iterator)

- (RocksDBIterator *)iterator;
- (RocksDBIterator *)iteratorWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;

@end

@interface RocksDB (Snapshot)

- (RocksDBSnapshot *)snapshot;
- (RocksDBSnapshot *)snapshotWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;

@end
