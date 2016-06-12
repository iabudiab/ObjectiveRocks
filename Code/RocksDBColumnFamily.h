//
//  RocksDBColumnFamily.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"
#import	"RocksDBOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Column Families provide a way to logically partition the database. Each key-value pair in RocksDB is associated 
 with exactly one Column Family. If there is no Column Family specified, key-value pair is associated with Column 
 Family "default".

 The `RocksDBColumnFamily` is a subclass of the `RocksDB`, which means that all methods are inherited. Nevertheless, 
 a Column Family can only be created via a `RocksDB` instance, thus all initializers are unavailable.
 */
@interface RocksDBColumnFamily : RocksDB

+ (instancetype)databaseAtPath:(NSString *)path
				  andDBOptions:(nullable void (^)(RocksDBOptions *options))options __attribute__((unavailable("Create column family via a RocksDB instance")));
+ (instancetype)databaseAtPath:(NSString *)path
				columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
			andDatabaseOptions:(nullable void (^)(RocksDBDatabaseOptions *options))options __attribute__((unavailable("Create column family via a RocksDB instance")));

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))

+ (instancetype)databaseForReadOnlyAtPath:(NSString *)path
							 andDBOptions:(nullable void (^)(RocksDBOptions *options))options __attribute__((unavailable("Create column family via a RocksDB instance")));
+ (instancetype)databaseForReadOnlyAtPath:(NSString *)path
						   columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
					   andDatabaseOptions:(nullable void (^)(RocksDBDatabaseOptions *options))options __attribute__((unavailable("Create column family via a RocksDB instance")));
#endif

+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path __attribute__((unavailable("Use the superclass RocksDB instead")));
- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
										 andOptions:(nullable void (^)(RocksDBColumnFamilyOptions *options))optionsBlock __attribute__((unavailable("Use the superclass RocksDB instead")));

/**
 @breaf Drops this Column Family form the DB instance it is associated with.
 */
- (void)drop;

@end

NS_ASSUME_NONNULL_END
