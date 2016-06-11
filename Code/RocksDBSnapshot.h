//
//  RocksDBSnapshot.h
//  ObjectiveRocks
//
//  Created by Iska on 06/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDB.h"
#import "RocksDBReadOptions.h"
#import "RocksDBSnapshotUnavailable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `RocksDBSnapshot` provides a consistent read-only view over the state of the key-value store.
 */
@interface RocksDBSnapshot : RocksDB

/** @brief Returns the Snapshot's sequence number. */
- (uint64_t)sequenceNumber;

@end

/**
 This category marks all mutating method inherited form the `RocksDB` parent class as unavailable since the
 `RocksDBSnapshot` is a read-only unmodifiable view over the DB.
 */
@interface RocksDBSnapshot (Unavailable)

+ (instancetype)databaseAtPath:(NSString *)path
				  andDBOptions:(void (^)(RocksDBOptions *options))options UNAVAILABLE("Create a snapshot via a DB instance");
+ (instancetype)databaseAtPath:(NSString *)path
				columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
			andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))options UNAVAILABLE("Create a snapshot via a DB instance");

#ifndef ROCKSDB_LITE

+ (instancetype)databaseForReadOnlyAtPath:(NSString *)path
							 andDBOptions:(void (^)(RocksDBOptions *options))options UNAVAILABLE("Create a snapshot via a DB instance");
+ (instancetype)databaseForReadOnlyAtPath:(NSString *)path
						   columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
					   andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))options UNAVAILABLE("Create a snapshot via a DB instance");
- (RocksDBColumnFamilyMetaData *)columnFamilyMetaData UNAVAILABLE("Column Family API not available");
#endif

+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path UNAVAILABLE("Column Family API not available");

- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
										 andOptions:(void (^)(RocksDBColumnFamilyOptions *options))optionsBlock UNAVAILABLE("Column Family API not available");
- (NSArray *)columnFamilies UNAVAILABLE("Column Family API not available");

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions UNAVAILABLE("Specify options when creating snapshot via DB instance");

- (RocksDBSnapshot *)snapshot UNAVAILABLE("Yo Dawg, Snapshot in Snapshot ... ");
- (RocksDBSnapshot *)snapshotWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions  UNAVAILABLE("Yo Dawg, Snapshot in Snapshot ... ");

#define NA_SELECTOR(sel) sel UNAVAILABLE("Snapshot is read-only");
SNAPSHOT_PUT_MERGE_DELETE_SELECTORS
#undef NA_SELECTOR

#ifndef ROCKSDB_LITE
#define NA_SELECTOR(sel) sel UNAVAILABLE("Snapshot is read-only");
SNAPSHOT_WRITE_BATCH_SELECTORS
#undef NA_SELECTOR
#endif

@end

NS_ASSUME_NONNULL_END
