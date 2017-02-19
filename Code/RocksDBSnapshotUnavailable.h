//
//  RocksDBSnapshotUnavailable.h
//  ObjectiveRocks
//
//  Created by Iska on 13/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#define UNAVAILABLE(x) __attribute__((unavailable(x)))

#define SNAPSHOT_PUT_MERGE_DELETE_SELECTORS \
NA_SELECTOR(- (BOOL)setData:(NSData *)anObject forKey:(NSData *)aKey error:(NSError * _Nullable *)error) \
NA_SELECTOR(- (BOOL)setData:(NSData *)anObject forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error) \
\
NA_SELECTOR(- (BOOL)mergeData:(NSData *)anObject forKey:(NSData *)aKey error:(NSError * _Nullable *)error) \
NA_SELECTOR(- (BOOL)mergeData:(NSData *)anObject forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error) \
\
NA_SELECTOR(- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError * _Nullable *)error) \
NA_SELECTOR(- (BOOL)deleteDataForKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error) \
\

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))

#define SNAPSHOT_WRITE_BATCH_SELECTORS \
NA_SELECTOR(- (RocksDBWriteBatch *)writeBatch) \
NA_SELECTOR(- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError * _Nullable *)error) \
NA_SELECTOR(- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error) \
\
NA_SELECTOR(- (RocksDBIndexedWriteBatch *)indexedWriteBatch) \
NA_SELECTOR(- (BOOL)performIndexedWriteBatch:(void (^)(RocksDBIndexedWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError * _Nullable *)error) \

#endif
