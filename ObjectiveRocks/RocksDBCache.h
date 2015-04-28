//
//  RocksDBCache.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBCache : NSObject

+ (instancetype)LRUCacheWithCapacity:(size_t)capacity;
+ (instancetype)LRUCacheWithCapacity:(size_t)capacity numShardsBits:(int)numShardBits;

@end
