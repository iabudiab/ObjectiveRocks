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

@interface RocksDBSnapshot : RocksDB

- (uint64_t)sequenceNumber;

@end

@interface RocksDBSnapshot (Unavailable)

- (instancetype)initWithPath:(NSString *)path UNAVAILABLE("Create a snapshot via a DB instance");
- (instancetype)initWithPath:(NSString *)path
				andDBOptions:(void (^)(RocksDBOptions *options))options UNAVAILABLE("Create a snapshot via a DB instance");
- (instancetype)initWithPath:(NSString *)path
			  columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
		  andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))options UNAVAILABLE("Create a snapshot via a DB instance");

+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path UNAVAILABLE("Column Family API not available");

- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
										 andOptions:(void (^)(RocksDBColumnFamilyOptions *options))optionsBlock UNAVAILABLE("Column Family API not available");
- (RocksDBColumnFamilyMetaData *)columnFamilyMetaData UNAVAILABLE("Column Family API not available");
- (NSArray *)columnFamilies UNAVAILABLE("Column Family API not available");

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions UNAVAILABLE("Specify options when creating snapshot via DB instance");

- (RocksDBSnapshot *)snapshot UNAVAILABLE("Yo Dawg, Snapshot in Snapshot ... ");
- (RocksDBSnapshot *)snapshotWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions  UNAVAILABLE("Yo Dawg, Snapshot in Snapshot ... ");

#define NA_SELECTOR(sel) sel UNAVAILABLE("Snapshot is read-only");
SNAPSHOT_PUT_MERGE_DELETE_SELECTORS
#undef NA_SELECTOR

@end
