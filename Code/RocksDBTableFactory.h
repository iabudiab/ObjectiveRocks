//
//  RocksDBTableFactory.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBBlockBasedTableOptions.h"

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))
#import "RocksDBPlainTableOptions.h"
#import "RocksDBCuckooTableOptions.h"
#endif

/** A factory for the TableFactory objects. */
@interface RocksDBTableFactory : NSObject

/** 
 Returns a BlockBased Table Factory object with thge given BlockBased table options.
 
 This is the default SST table format in RocksDB.

 @see RocksDBBlockBasedTableOptions
 */
+ (instancetype)blockBasedTableFactoryWithOptions:(void (^)(RocksDBBlockBasedTableOptions *options))options;

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))
/**
 Returns a Plain Table Factory object with thge given Plain table options.
 
 This is a RocksDB’s SST file format optimized for low query latency on pure-memory or really low-latency media

 @see RocksDBPlainTableOptions
 */
+ (instancetype)plainTableFactoryWithOptions:(void (^)(RocksDBPlainTableOptions *options))options;

/**
 Returns a Cuckoo Table Factory object with thge given Cuckoo table options.
 
 This is designed for applications that require fast point lookups but not fast range scans.

 @see RocksDBCuckooTableOptions
 */
+ (instancetype)cuckooTableFactoryWithOptions:(void (^)(RocksDBCuckooTableOptions *options))options;
#endif

@end
