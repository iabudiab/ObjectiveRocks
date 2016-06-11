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

#ifndef ROCKSDB_LITE
#import "RocksDBColumnFamilyMetaData.h"
#import "RocksDBIndexedWriteBatch.h"
#import "RocksDBProperties.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class RocksDBColumnFamily;
@class RocksDBSnapshot;

@interface RocksDB : NSObject

#pragma mark - Initializing the database
///--------------------------------
/// @name Initializing the database
///--------------------------------

/**
 Intializes a DB instance with the given path and configured with the given options.

 @discussion This method initializes the DB with the default Column Family and allows for
 configuring the DB via the RocksDBOptions block. The block gets a single  argument, an
 instance of `RocksDBOptions`, which is initialized with the default values and passed for 
 further tuning. If the options block is `nil`, then default settings will be used.

 @param path The file path of the DB.
 @param options A block with a single argument, an instance of `RocksDBOptions`.
 @return The newly-intialized DB instance with the given path and options.

 @see RocksDBOptions
 @see RocksDBColumnFamily

 @warning When opening a DB in a read-write mode, you need to specify all Column Families
 that currently exist in the DB.
 */
+ (nullable instancetype)databaseAtPath:(NSString *)path
						   andDBOptions:(nullable void (^)(RocksDBOptions *options))options;

/** 
 Intializes a DB instance and opens the defined Column Families.

 @param path The file path of the database.
 @param descriptor The descriptor holds the names and the options of the existing Column Families 
 in the DB.
 @param options A block with a single argument, an instance of `RocksDBDatabaseOptions`, which can
 be used to tune the DB configuration.
 @return The newly-intialized DB instance with the given path and database options. Furthermore, the
 DB instance also opens the defined Column Families.

 @see RocksDBColumnFamily
 @see RocksDBColumnFamilyDescriptor
 @see RocksDBOptions
 @see RocksDBDatabaseOptions

 @remark The `RocksDBDatabaseOptions` differs from the `RocksDBOptions` as it holds only database-wide
 configuration settings.

 @warning When opening a DB in a read-write mode, you need to specify all Column Families
 that currently exist in the DB.
 */
+ (nullable instancetype)databaseAtPath:(NSString *)path
						 columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
					 andDatabaseOptions:(nullable void (^)(RocksDBDatabaseOptions *options))options;

#ifndef ROCKSDB_LITE

/**
 Intializes a DB instance for read-only with the given path and configured with the given options.

 @discussion This method initializes the DB for read-only mode with the default Column Family and
 allows for configuring the DB via the RocksDBOptions block. The block gets a single  argument, an
 instance of `RocksDBOptions`, which is initialized with the default values and passed for
 further tuning. If the options block is `nil`, then default settings will be used.

 All DB interfaces that modify data, like put/delete, will return error. In read-only mode no
 compactions will happen.

 @param path The file path of the DB.
 @param options A block with a single argument, an instance of `RocksDBOptions`.
 @return The newly-intialized DB instance with the given path and options.

 @see RocksDBOptions
 
 @remark Opening a non-existing database in read-only mode wont have any effect, even
 if `createIfMissing` option is set.
 */
+ (nullable instancetype)databaseForReadOnlyAtPath:(NSString *)path
									  andDBOptions:(nullable void (^)(RocksDBOptions *options))options;

/**
 Intializes a DB instance for read-only and opens the defined Column Families.

 @discussion All DB interfaces that modify data, like put/delete, will return error. In read-only mode no
 compactions will happen.

 @param path The file path of the database.
 @param descriptor The descriptor holds the names and the options of the existing Column Families
 in the DB.
 @param options A block with a single argument, an instance of `RocksDBDatabaseOptions`, which can
 be used to tune the DB configuration.
 @return The newly-intialized DB instance with the given path and database options. Furthermore, the
 DB instance also opens the defined Column Families.

 @see RocksDBColumnFamily
 @see RocksDBColumnFamilyDescriptor
 @see RocksDBOptions
 @see RocksDBDatabaseOptions

 @remark The `RocksDBDatabaseOptions` differs from the `RocksDBOptions` as it holds only database-wide
 configuration settings.

 @remark Opening a non-existing database in read-only mode wont have any effect, even
 if `createIfMissing` option is set.

 @remark When opening DB with read only, it is possible to specify only a subset of column families 
 in the database that should be opened. However, default column family must specified.
 */
+ (nullable instancetype)databaseForReadOnlyAtPath:(NSString *)path
									columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
								andDatabaseOptions:(nullable void (^)(RocksDBDatabaseOptions *options))options;

#endif

/** @brief Closes the database instance */
- (void)close;

/** 
 Sets the default read & write options for all database operations.

 @param readOptions A block with an instance of `RocksDBReadOptions` which configures the behaviour of read
 operations in the DB.
 @param writeOptions A block with an instance of `RocksDBWriteOptions` which configures the behaviour of write
 operations in the DB.

 @see RocksDBReadOptions
 @see RocksDBWriteOptions
 */
- (void)setDefaultReadOptions:(nullable void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

@end

@interface RocksDB (ColumnFamilies)

#pragma mark - Column Family Management
///--------------------------------
/// @name Column Family Management
///--------------------------------

/**
 Lists all existing Column Families in the DB residing under the given path.

 @param path The file path of the database.
 @return An array containing all Column Families currently present in the DB.

 @see RocksDBColumnFamily
 */
+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path;

/**
 Creates a new Column Family with the given name and options.
 
 @param name The name of the new Column Family.
 @param options A block with a `RocksDBColumnFamilyOptions` instance for configuring the
 new Column Family.
 @return The newly-created Column Family with the given name and options.

 @see RocksDBColumnFamily
 @see RocksDBColumnFamilyOptions
 */
- (nullable RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
												  andOptions:(nullable void (^)(RocksDBColumnFamilyOptions *options))options;

/** @brief Returns an array */
- (NSArray *)columnFamilies;

#ifndef ROCKSDB_LITE

/**
 Returns the Meta Data object for the Column Family associated with this instance.

 @see RocksDBColumnFamilyMetaData

 @warning Not available in RocksDB Lite.
 */
- (RocksDBColumnFamilyMetaData *)columnFamilyMetaData;

#endif

@end

#ifndef ROCKSDB_LITE

@interface RocksDB (Properties)

#pragma mark - Database properties
///--------------------------------
/// @name Database properties
///--------------------------------

/**
 Returns the string value for the given property.

 @param property The property name.
 @return The string value of the property.

 @see RocksDBProperties.h

 @warning Not available in RocksDB Lite.
 */
- (nullable NSString *)valueForProperty:(RocksDBProperty)property;

/**
 Returns the integer value for the given int property name.

 @param property The property name.
 @return The integer value of the property.

 @see RocksDBProperties.h

 @warning Not available in RocksDB Lite.
 */
- (uint64_t)valueForIntProperty:(RocksDBIntProperty)property;

@end

#endif

@interface RocksDB (WriteOps)

#pragma mark - Write operations
///--------------------------------
/// @name Write operations
///--------------------------------

/**
 Stores the given key-object pair into the DB.

 @param anObject The object for key.
 @param aKey The key for object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise
 */
- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError * _Nullable *)error;

/**
 Stores the given key-object pair into the DB.

 @discussion

 @param anObject The object for key.
 @param aKey The key for object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions A block with a `RocksDBWriteOptions` instance for configuring this write operation.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBWriteOptions
 */
- (BOOL)setObject:(id)anObject forKey:(id)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error;

/**
 Stores the given data object under the given data key in the DB.

 @param data The data for key.
 @param aKey The key for object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDB setObject:forKey:
 @see RocksDB setObject:forKey:error:
 @see RocksDB setObject:forKey:writeOptions:
 @see RocksDB setObject:forKey:error:writeOptions:
 */
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError * _Nullable *)error;

/**
 Stores the given data object under the given data key in the DB.

 @discussion This method can be used to configure single write operations bypassing the defaults.

 @param data The data for key.
 @param aKey The key for object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions A block with a `RocksDBWriteOptions` instance for configuring this write operation.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDB setObject:forKey:
 @see RocksDB setObject:forKey:error:
 @see RocksDB setObject:forKey:writeOptions:
 @see RocksDB setObject:forKey:error:writeOptions:
 */
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error;

@end

@interface RocksDB (MergeOps)

#pragma mark - Merge operations
///--------------------------------
/// @name Merge operations
///--------------------------------


- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey error:(NSError * _Nullable *)error;
- (BOOL)mergeOperation:(NSString *)aMerge forKey:(id)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error;

/**
 Merges the given object with the existing data for the given key.

 @discussion A merge is an atomic read-modify-write operation, whose semantics are defined
 by the user-provided merge operator.

 @param anObject The object being merged.
 @param aKey The key for the object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBMergeOperator
 */
- (BOOL)mergeObject:(id)anObject forKey:(id)aKey error:(NSError * _Nullable *)error;

/**
 Merges the given object with the existing data for the given key.

 @discussion A merge is an atomic read-modify-write operation, whose semantics are defined
 by the user-provided merge operator.
 This method can be used to configure single write operations bypassing the defaults.

 @param anObject The object being merged.
 @param aKey The key for the object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions A block with a `RocksDBWriteOptions` instance for configuring this merge operation.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBMergeOperator
 */
- (BOOL)mergeObject:(id)anObject forKey:(id)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error ;


/**
 Merges the given data object with the existing data for the given key.

 @discussion A merge is an atomic read-modify-write operation, whose semantics are defined
 by the user-provided merge operator.

 @param data The data being merged.
 @param aKey The key for the data.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBMergeOperator
 */
- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey error:(NSError * _Nullable *)error;

/**
 Merges the given data object with the existing data for the given key.

 @discussion A merge is an atomic read-modify-write operation, whose semantics are defined
 by the user-provided merge operator. 
 This method can be used to configure single write operations bypassing the defaults.

 @param data The data being merged.
 @param aKey The key for the data.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions A block with a `RocksDBWriteOptions` instance for configuring this merge operation.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBMergeOperator
 @see RocksDBWriteOptions
 */
- (BOOL)mergeData:(NSData *)data forKey:(NSData *)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error;

@end

@interface RocksDB (ReadOps)

#pragma mark - Read operations
///--------------------------------
/// @name Read operations
///--------------------------------

/**
 Returns the object for the given key.

 @peram aKey The key for object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return The object for the given key.
 */
- (nullable id)objectForKey:(id)aKey error:(NSError * _Nullable *)error;

/**
 Returns the object for the given key.

 @peram aKey The key for object.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param readOptions A block with a `RocksDBReadOptions` instance for configuring this read operation.
 @return The object for the given key.

 @see RocksDBReadOptions
 */
- (nullable id)objectForKey:(id)aKey readOptions:(nullable void (^)(RocksDBReadOptions *readOptions))readOptions error:(NSError * _Nullable *)error;

/**
 Returns the data for the given key.

 @peram aKey The key for data.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return The data object for the given key.

 @see RocksDB objectForKey:
 @see RocksDB objectForKey:error:
 @see RocksDB objectForKey:readOptions:
 @see RocksDB objectForKey:error:readOptions:
 */
- (nullable NSData *)dataForKey:(NSData *)aKey error:(NSError * _Nullable *)error;

/**
 Returns the data for the given key.

 @peram aKey The key for data.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param readOptions A block with a `RocksDBReadOptions` instance for configuring this read operation.
 @return The data object for the given key.
 
 @see RocksDBReadOptions
 @see RocksDB objectForKey:
 @see RocksDB objectForKey:error:
 @see RocksDB objectForKey:readOptions:
 @see RocksDB objectForKey:error:readOptions:
 */
- (nullable NSData *)dataForKey:(NSData *)aKey readOptions:(nullable void (^)(RocksDBReadOptions *readOptions))readOptions error:(NSError * _Nullable *)error;

@end

@interface RocksDB (DeleteOps)

#pragma mark - Delete operations
///--------------------------------
/// @name Delete operations
///--------------------------------

/**
 Deletes the object for the given key.

 @peram aKey The key to delete.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise
 */
- (BOOL)deleteObjectForKey:(id)aKey error:(NSError * _Nullable *)error;

/**
 Deletes the object for the given key.

 @peram aKey The key to delete.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions A block with a `RocksDBWriteOptions` instance for configuring this delete operation.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBWriteOptions
 */
- (BOOL)deleteObjectForKey:(id)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error ;

/**
 Deletes the data for the given key.

 @peram aKey The key to delete.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDB deleteObjectForKey:
 @see RocksDB deleteObjectForKey:error:
 @see RocksDB deleteObjectForKey:readOptions:
 @see RocksDB deleteObjectForKey:error:readOptions:
 */
- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError * _Nullable *)error;

/**
 Deletes the data for the given key.

 @peram aKey The key to delete.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions A block with a `RocksDBWriteOptions` instance for configuring this delete operation.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBWriteOptions
 @see RocksDB deleteObjectForKey:
 @see RocksDB deleteObjectForKey:error:
 @see RocksDB deleteObjectForKey:readOptions:
 @see RocksDB deleteObjectForKey:error:readOptions:
 */
- (BOOL)deleteDataForKey:(NSData *)aKey writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error;

@end

@interface RocksDB (WriteBatch)

#pragma mark - Atomic Writes
///--------------------------------
/// @name Atomic Writes
///--------------------------------

/**
 Returns a write batch instance, which can be used to perform a set of updates to the database atomically.

 @discussion This batch instance can be applied at a later point to the DB, making it more flexible 
 for “scattered” logic.

 @see RocksDBWriteBatch
 */
- (RocksDBWriteBatch *)writeBatch;

/**
 Performs a write batch on this DB.

 @discussion All the operations stored to the batch instance are written atomically to DB when the
 block is executed.

 @param batch A block with `RocksDBWriteBatch` instance and `RocksDBWriteOptions` to configure the batch.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBWriteBatch
 */
- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError * _Nullable *)error;

/**
 Applies a write batch instance on this DB.

 @discussion In contrast to the block-based approach, this method allows for building the batch separately
 and then applying it when needed.

 @param writeBatch The write batch instance to apply.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @param writeOptions The write options to configure this batch.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBWriteBatch
 @see RocksDBWriteOptions
 */
- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch writeOptions:(nullable void (^)(RocksDBWriteOptions *writeOptions))writeOptions error:(NSError * _Nullable *)error;

#ifndef ROCKSDB_LITE

/**
 Returns an instance of an indexed write batch, which can be used to perform a set of
 updates to the database atomically.

 @discussion The indexed write batch builds a searchable index, that can be read and
 iterated before applying it to the database.

 @see RocksDBIndexedWriteBatch
 */
- (RocksDBIndexedWriteBatch *)indexedWriteBatch;

/**
 Performs an indexed write batch on this DB.

 @discussion All the operations stored to the batch instance are written atomically to DB when the
 block is executed.

 @param batch A block with `RocksDBIndexedWriteBatch` instance and `RocksDBWriteOptions` to configure the batch.
 @return `YES` if the operation succeeded, `NO` otherwise

 @see RocksDBIndexedWriteBatch
 */
- (BOOL)performIndexedWriteBatch:(void (^)(RocksDBIndexedWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError * _Nullable *)error;

#endif

@end

@interface RocksDB (Iterator)

#pragma mark - Database Iterator
///--------------------------------
/// @name Database Iterator
///--------------------------------

/**
 Returns an iterator instance for scan operations.

 @return An iterator instace.

 @see RocksDBIterator
 */
- (RocksDBIterator *)iterator;

/**
 Returns an iterator instance for scan operations

 @param readOptions A block with a `RocksDBReadOptions` instance for configuring the iterator instance.
 @return An iterator instace.

 @see RocksDBIterator
 @see RocksDBReadOptions
 */
- (RocksDBIterator *)iteratorWithReadOptions:(nullable void (^)(RocksDBReadOptions *readOptions))readOptions;

@end

@interface RocksDB (Snapshot)

#pragma mark - Database Snapshot
///--------------------------------
/// @name Database Snapshot
///--------------------------------

/**
 Returns a snapshot of the DB. A snapshot provides consistent read-only view over the state of the key-value store.

 @see RocksDBSnapshot
 */
- (RocksDBSnapshot *)snapshot;

/**
 Returns a snapshot of the DB. A snapshot provides consistent read-only view over the state of the key-value store.

 @param readOptions A block with a `RocksDBReadOptions` instance for configuring the returned snapshot instance.

 @see RocksDBSnapshot
 @see RocksDBReadOptions
 */
- (RocksDBSnapshot *)snapshotWithReadOptions:(nullable void (^)(RocksDBReadOptions *readOptions))readOptions;

@end

NS_ASSUME_NONNULL_END
