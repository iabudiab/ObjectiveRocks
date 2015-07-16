//
//  RocksDBPlainTableOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, PlainTableEncodingType)
{
	PlainTableEncodingPlain,
	PlainTableEncodingPrefix
};

@interface RocksDBPlainTableOptions : NSObject


/**
 @brief
  Plain table has optimization for fix-sized keys, which can
  be specified via userKeyLen.
 */
@property (nonatomic, assign) uint32_t userKeyLen;

/**
 @brief
  The number of bits used for bloom filer per prefix.
  To disable it pass a zero.
 */
@property (nonatomic, assign) int bloomBitsPerKey;

/**
 @brief
  The desired utilization of the hash table used for prefix hashing.
  `hashTableRatio` = number of prefixes / #buckets in the hash table.
 */
@property (nonatomic, assign) double hashTableRatio;

/**
 @brief
  Used to build one index record inside each prefix for the number of
  keys for the binary search inside each hash bucket.
 */
@property (nonatomic, assign) size_t indexSparseness;

/**
 @brief
  Huge page TLB size. The user needs to reserve huge pages 
  for it to be allocated, like:
  `sysctl -w vm.nr_hugepages=20`
 */
@property (nonatomic, assign) size_t hugePageTlbSize;

/**
 @brief
  Encoding type for the keys. The value will determine how to encode keys
  when writing to a new SST file.
 */
@property (nonatomic, assign) PlainTableEncodingType encodingType;

/**
 @brief
  Mode for reading the whole file one record by one without using the index.
 */
@property (nonatomic, assign) BOOL fullScanMode;

/**
 @brief
  Compute plain table index and bloom filter during file building and store
  it in file. When reading file, index will be mmaped instead of recomputation.
 */
@property (nonatomic, assign) BOOL storeIndexInFile;

@end
