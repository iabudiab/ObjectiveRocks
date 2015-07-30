//
//  RocksDBColumnFamily.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"
#import	"RocksDBOptions.h"

/**
 Column Families provide a way to logically partition the database. Each key-value pair in RocksDB is associated 
 with exactly one Column Family. If there is no Column Family specified, key-value pair is associated with Column 
 Family "default".

 The `RocksDBColumnFamily` is a subclass of the `RocksDB`, which means that all methods are inherited. Nevertheless, 
 a Column Family can only be created via a `RocksDB` instance, thus all initializers are unavailable.
 */
@interface RocksDBColumnFamily : RocksDB

- (instancetype)initWithPath:(NSString *)path __attribute__((unavailable("Create column family via a RocksDB instance")));
- (instancetype)initWithPath:(NSString *)path
				andDBOptions:(void (^)(RocksDBOptions *options))options __attribute__((unavailable("Create column family via a RocksDB instance")));
- (instancetype)initWithPath:(NSString *)path
			  columnFamilies:(RocksDBColumnFamilyDescriptor *)descriptor
		  andDatabaseOptions:(void (^)(RocksDBDatabaseOptions *options))options __attribute__((unavailable("Create column family via a RocksDB instance")));

+ (NSArray *)listColumnFamiliesInDatabaseAtPath:(NSString *)path __attribute__((unavailable("Use the superclass RocksDB instead")));
- (RocksDBColumnFamily *)createColumnFamilyWithName:(NSString *)name
										 andOptions:(void (^)(RocksDBColumnFamilyOptions *options))optionsBlock __attribute__((unavailable("Use the superclass RocksDB instead")));

/**
 @breaf Drops this Column Family form the DB instance it is associated with.
 */
- (void)drop;

@end
