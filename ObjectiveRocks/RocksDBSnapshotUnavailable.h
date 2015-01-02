//
//  RocksDBSnapshotUnavailable.h
//  ObjectiveRocks
//
//  Created by Iska on 13/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#define NA(x) __attribute__((unavailable(x)))

#define SNAPSHOT_PUT_MERGE_DELETE_SELECTORS \
NA_SELECTOR(- (BOOL)setObject:(id)anObject forKey:(id)aKey) \
NA_SELECTOR(- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)setObject:(id)anObject forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptionsBlock) \
NA_SELECTOR(- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey) \
NA_SELECTOR(- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (BOOL)mergeObject:(id)anObject forKey:(id)aKey) \
NA_SELECTOR(- (BOOL)mergeObject:(id)anObject forKey:(id)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)mergeObject:(id)anObject forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)mergeObject:(id)anObject forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey) \
NA_SELECTOR(- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey) \
NA_SELECTOR(- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (BOOL)deleteObjectForKey:(id)aKey) \
NA_SELECTOR(- (BOOL)deleteObjectForKey:(id)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)deleteObjectForKey:(id)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)deleteObjectForKey:(id)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (BOOL)deleteDataForKey:(NSData *)aKey) \
NA_SELECTOR(- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error) \
NA_SELECTOR(- (BOOL)deleteDataForKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
\
NA_SELECTOR(- (RocksDBWriteBatch *)writeBatch) \
NA_SELECTOR(- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch) \
NA_SELECTOR(- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError **)error) \
NA_SELECTOR(- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
NA_SELECTOR(- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions) \
