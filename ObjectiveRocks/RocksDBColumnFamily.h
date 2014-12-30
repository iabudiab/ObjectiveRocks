//
//  RocksDBColumnFamily.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDB.h"
#import	"RocksDBOptions.h"

namespace rocksdb {
	class DB;
	class ColumnFamilyHandle;
}

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

- (instancetype)initWithDBInstance:(rocksdb::DB *)db
					  columnFamily:(rocksdb::ColumnFamilyHandle *)columnFamily
						andOptions:(RocksDBOptions *)options;

- (void)drop;

@end
