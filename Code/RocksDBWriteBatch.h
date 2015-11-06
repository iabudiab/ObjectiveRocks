//
//  RocksDBWriteBatch.h
//  ObjectiveRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBEncodingOptions.h"

@class RocksDBColumnFamily;

/**
 The `RocksDBWriteBatch` allows to place multiple updates in the same "batch" and apply them together
 using a synchronous write. Operations on a Write Batch instance have no effect if not applied to a DB
 instance, i.e. the Write Batch accumulates all modifications that are to be performed when applying
 to a DB instance. Write batches can also span multiple Column Families.

 @warning If not specified otherwise, Write Batch operations are applied to the Column Family
 used when initiazing the Batch instance.
 */
@interface RocksDBWriteBatch : NSObject

/**
 Stores the given key-object pair into the Write Batch.

 @param anObject The object for key.
 @param aKey The key for object.
 */
- (void)setObject:(id)anObject forKey:(id)aKey;

/**
 Stores the given key-data pair into the Write Batch.

 @param data The data for key.
 @param aKey The key for object.
 */
- (void)setData:(NSData *)data forKey:(NSData *)aKey;

/**
 Stores the given key-object pair for the given Column Family into the Write Batch.

 @param anObject The object for key.
 @param aKey The key for object.
 @param columnFamily The column family where data should be written.
 */
- (void)setObject:(id)anObject forKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Stores the given key-data pair for the given Column Family into the Write Batch.

 @param data The data for key.
 @param aKey The key for object.
 @param columnFamily The column family where data should be written.
 */
- (void)setData:(NSData *)data forKey:(NSData *)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Perform the merge operation in the Write Batch.

 @param aMerge A merge opration.
 @param aKey The key for the merge.
 */
- (void)mergeOperation:(NSString *)aMerge forKey:(id)aKey;

/**
 Perform the merge operation for the given Column Family in the Write Batch.

 @param aMerge A merge opration.
 @param aKey The key for the merge.
 @param columnFamily The column family where data should be merged.
 */
- (void)mergeOperation:(NSString *)aMerge forKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Merges the given key-object pair into the Write Batch.

 @param anObject The object for key.
 @param aKey The key for object.
 */
- (void)mergeObject:(id)anObject forKey:(id)aKey;

/**
 Merges the given key-object pair into the Write Batch.

 @param anObject The object for key.
 @param aKey The key for object.
 */
- (void)mergeData:(NSData *)data forKey:(NSData *)aKey;


/**
 Merges the given key-object pair for the given Column Family into the Write Batch.

 @param anObject The object for key.
 @param aKey The key for object.
 @param columnFamily The column family where data should be written.
 */
- (void)mergeObject:(id)anObject forKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Merges the given key-data pair for the given Column Family into the Write Batch.

 @param data The data for key.
 @param aKey The key for object.
 @param columnFamily The column family where data should be written.
 */
- (void)mergeData:(NSData *)data forKey:(NSData *)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Deletes the object for the given key from this Write Batch.

 @param aKey The key to delete.
 */
- (void)deleteObjectForKey:(id)aKey;

/**
 Deletes the data for the given key from this Write Batch.

 @param aKey The key to delete.
 */
- (void)deleteDataForKey:(NSData *)aKey;

/**
 Deletes the object for the given key in the given Column Family from this Write Batch.

 @param data The data for key.
 @param aKey The key for object.
 @param columnFamily The column family from which the data should be deleted.
 */
- (void)deleteObjectForKey:(id)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Deletes the object for the given key in the given Column Family from the Write Batch.

 @param data The data for key.
 @param aKey The key for object.
 @param columnFamily The column family from which the data should be deleted.
 */
- (void)deleteDataForKey:(NSData *)aKey inColumnFamily:(RocksDBColumnFamily *)columnFamily;

/**
 Append a blob of arbitrary size to the records in this batch. Blobs, puts, deletes, and merges 
 will be encountered in the same order in thich they were inserted. The blob will NOT consume 
 sequence number(s) and will NOT increase the count of the batch.

 Example application: add timestamps to the transaction log for use in replication.
 */
- (void)putLogData:(NSData *)logData;

/** @brief Clear all updates buffered in this batch. */
- (void)clear;

/** @brief Returns the number of updates in the batch. */
- (int)count;

/** @brief Retrieve the serialized version of this batch. */
- (NSData *)data;

/** @brief Retrieve data size of the batch. */
- (size_t)dataSize;

@end
