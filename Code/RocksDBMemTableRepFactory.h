//
//  RocksDBMemTableRepFactory.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A factory for MemTableRep objects
 */
@interface RocksDBMemTableRepFactory : NSObject

/**
 Creates MemTableReps that use a skip list to store keys.
 This is the default in RocksDB.
 */
+ (instancetype)skipListRepFacotry;

#ifndef ROCKSDB_LITE

/**
 Creates MemTableReps that are backed by an std::vector.
 On iteration, the vector is sorted. This is useful for workloads 
 where iteration is very rare and writes are generally not issued 
 after reads begin.
 */
+ (instancetype)vectorRepFactory;

/**
 Creates MemTableRep that contain a fixed array of buckets, each
 pointing to a skiplist.
 */
+ (instancetype)hashSkipListRepFactory;

/**
 Creates MemTableRep based on a hash table: it contains a fixed
 array of buckets, each pointing to either a linked list or a skip 
 list if number of entries inside the bucket exceeds a predefined 
 threshold.
 */
+ (instancetype)hashLinkListRepFactory;

/**
 Creates cuckoo-hashing based MemTableRep. Cuckoo-hash is a closed-hash 
 strategy, in which all key/value pairs are stored in the bucket array 
 itself intead of in some data structures external to the bucket array.
 
 @param writeBufferSize The write buffer size in bytes.
 */
+ (instancetype)hashCuckooRepFactoryWithWriteBufferSize:(size_t)writeBufferSize;

#endif

@end
