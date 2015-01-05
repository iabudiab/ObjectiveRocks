//
//  RocksDBTableFactory.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBBlockBasedTableOptions.h"

#ifndef ROCKSDB_LITE
#import "RocksDBPlainTableOptions.h"
#import "RocksDBCuckooTableOptions.h"
#endif

@interface RocksDBTableFactory : NSObject

+ (instancetype)blockBasedTableFactoryWithOptions:(void (^)(RocksDBBlockBasedTableOptions *options))options;

#ifndef ROCKSDB_LITE
+ (instancetype)plainTableFactoryWithOptions:(void (^)(RocksDBPlainTableOptions *options))options;
+ (instancetype)cuckooTableFactoryWithOptions:(void (^)(RocksDBCuckooTableOptions *options))options;
#endif

@end
