//
//  RocksDBMemTableRepFactory.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBMemTableRepFactory : NSObject

+ (instancetype)skipListRepFacotry;

#ifndef ROCKSDB_LITE

+ (instancetype)vectorRepFactory;
+ (instancetype)hashSkipListRepFactory;
+ (instancetype)hashLinkListRepFactory;
+ (instancetype)hashCuckooRepFactoryWithWriteBufferSize:(size_t)writeBufferSize;

#endif

@end
