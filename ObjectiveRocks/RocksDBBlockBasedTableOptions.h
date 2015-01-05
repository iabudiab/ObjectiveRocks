//
//  RocksDBBlockBasedTableOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBCache.h"
#import "RocksDBFilterPolicy.h"

typedef NS_ENUM(char, BlockBasedTableIndexType)
{
	BlockBasedTableIndexBinarySearch,
	BlockBasedTableIndexHashSearch
};

typedef NS_ENUM(char, BlockBasedTableChecksumType) {
	BlockBasedTableNoChecksum = 0x0,  // not yet supported. Will fail
	BlockBasedTableChecksumCRC32c = 0x1,
	BlockBasedTableChecksumxxHash = 0x2,
};

@interface RocksDBBlockBasedTableOptions : NSObject

@property (nonatomic, assign) BOOL cacheIndexAndFilterBlocks;
@property (nonatomic, assign) BlockBasedTableIndexType indexType;
@property (nonatomic, assign) BOOL hashIndexAllowCollision;
@property (nonatomic, assign) BlockBasedTableChecksumType checksumType;
@property (nonatomic, assign) BOOL noBlockCache;
@property (nonatomic, strong) RocksDBCache *blockCache;
@property (nonatomic, strong) RocksDBCache *blockCacheCompressed;
@property (nonatomic, assign) size_t blockSize;
@property (nonatomic, assign) int blockSizeDeviation;
@property (nonatomic, assign) int blockRestartInterval;
@property (nonatomic, strong) RocksDBFilterPolicy *filterPolicy;
@property (nonatomic, assign) BOOL wholeKeyFiltering;

@end
