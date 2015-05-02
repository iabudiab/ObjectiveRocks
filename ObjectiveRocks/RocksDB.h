//
//  ObjectiveRocks.h
//  ObjectiveRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBColumnFamilyDescriptor.h"
#import "RocksDBColumnFamilyMetaData.h"
#import "RocksDBOptions.h"
#import "RocksDBReadOptions.h"
#import "RocksDBWriteOptions.h"
#import "RocksDBWriteBatch.h"
#import "RocksDBIterator.h"

@class RocksDBColumnFamily;
@class RocksDBSnapshot;

@interface RocksDB : NSObject

///--------------------------------
/// @name Initializing the database
///--------------------------------

/**
 Intializes a DB instance with the given path.

 @discussion This method initializes the DB with the default Column Family, uses the
 default DB and Column Family settings, and does not setup key/value encoders.

 @param path The path where the DB resides.
 @return The newly-intializad DB instance with the given path and default settings.

 @see RocksDBOptions
 @see RocksDBColumnFamily

 @warning When opening a DB in a read-write mode, you need to specify all Column Families 
 that currently exist in the DB.
 */
- (instancetype)initWithPath:(NSString *)path;

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
- (instancetype)initWithPath:(NSString *)path
				andDBOptions:(void (^)(RocksDBOptions *options))options;

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
- (instancetype)initWithPath:(NSString *)path
			  columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
		  andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))options;

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
- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

@end

@interface RocksDB (ColumnFamilies)

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
- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
										 andOptions:(void (^)(RocksDBColumnFamilyOptions *options))options;

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

- (NSString *)valueForProperty:(NSString *)property;
- (uint64_t)valueForIntProperty:(NSString *)property;

@end

#endif

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
