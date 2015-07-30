//
//  RocksDBFilterPolicy.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Defines a filter policy for keys.
 */
@interface RocksDBFilterPolicy : NSObject

/**
 Return a new filter policy that uses a bloom filter with approximately
 the specified number of bits per key.
 
 @param bitsPerKey The number of bits per key.
 */
+ (instancetype)bloomFilterPolicyWithBitsPerKey:(int)bitsPerKey;

/**
 Return a new filter policy that uses a bloom filter with approximately
 the specified number of bits per key.
 
 @param bitsPerKey The number of bits per key.
 @param useBlockBasedBuilder Use block-based builder.
 */
+ (instancetype)bloomFilterPolicyWithBitsPerKey:(int)bitsPerKey useBlockBasedBuilder:(BOOL)useBlockBasedBuilder;

@end
