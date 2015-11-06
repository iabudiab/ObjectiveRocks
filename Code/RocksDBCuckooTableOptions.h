//
//  RocksDBCuckooTableOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBCuckooTableOptions : NSObject

/**
 @brief
  Determines the utilization of hash tables. Smaller values
  result in larger hash tables with fewer collisions.
 */
@property (nonatomic, assign) double hashTableRatio;

/**
 @brief
  A property used by builder to determine the depth to go to
  to search for a path to displace elements in case of
  collision. Higher values result in more efficient hash tables 
  with fewer lookups but take more time to build.
 */
@property (nonatomic, assign) uint32_t maxSearchDepth;

/**
 @brief
  In case of collision while inserting, the builder
  attempts to insert in the next `cuckooBlockSize`
  locations before skipping over to the next Cuckoo hash
  function. This makes lookups more cache friendly in case
  of collisions.
 */
@property (nonatomic, assign) uint32_t cuckooBlockSize;

/**
 @brief
  If this option is enabled, user key is treated as uint64_t and its value
  is used as hash value directly. This option changes builder's behavior.
  Reader ignore this option and behave according to what specified in table
  property.
 */
@property (nonatomic, assign) BOOL identityAsFirstHash;

/**
 @brief
  If this option is set to true, module is used during hash calculation.
  This often yields better space efficiency at the cost of performance.
  If this optino is set to false, # of entries in table is constrained to be
  power of two, and bit and is used to calculate hash, which is faster in
  general.
 */
@property (nonatomic, assign) BOOL useModuleHash;

@end
