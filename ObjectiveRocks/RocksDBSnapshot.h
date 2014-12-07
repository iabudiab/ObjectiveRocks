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

namespace rocksdb {
	class DB;
}

@interface RocksDBSnapshot : RocksDB

- (instancetype)initWithDBInstance:(rocksdb::DB *)db andReadOptions:(RocksDBReadOptions *)readOptions;

@end

#define NA(x) __attribute__((unavailable(x)))

@interface RocksDBSnapshot (Unavailable)

- (instancetype)initWithPath:(NSString *)path NA("Create a snapshot via a DB instance");
- (instancetype)initWithPath:(NSString *)path
				andDBOptions:(void (^)(RocksDBOptions *options))options NA("Create a snapshot via a DB instance");

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Specify options when creating snapshot via DB instance");

- (BOOL)setData:(NSData *)data
		 forKey:(NSData *)aKey NA("Snapshots are read-only");
- (BOOL)setData:(NSData *)data
		 forKey:(NSData *)aKey
		  error:(NSError **)error NA("Snapshots are read-only");
- (BOOL)setData:(NSData *)data
		 forKey:(NSData *)aKey
   writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Snapshots are read-only");
- (BOOL)setData:(NSData *)data
		 forKey:(NSData *)aKey
		  error:(NSError **)error
   writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Snapshots are read-only");

- (BOOL)deleteDataForKey:(NSData *)aKey NA("Snapshots are read-only");
- (BOOL)deleteDataForKey:(NSData *)aKey
				   error:(NSError **)error NA("Snapshots are read-only");
- (BOOL)deleteDataForKey:(NSData *)aKey
			writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Snapshots are read-only");
- (BOOL)deleteDataForKey:(NSData *)aKey
				   error:(NSError **)error
			writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Snapshots are read-only");

- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch NA("Snapshots are read-only");
- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch
					error:(NSError **)error NA("Snapshots are read-only");
- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch
	   withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Snapshots are read-only");
- (BOOL)applyWriteBatch:(RocksDBWriteBatch *)writeBatch
				  error:(NSError **)error
		   writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions NA("Snapshots are read-only");

- (RocksDBSnapshot *)snapshot NA("Yo Dawg, Snapshot in Snapshot ... ");

@end
