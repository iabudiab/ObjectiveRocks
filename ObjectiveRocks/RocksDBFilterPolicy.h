//
//  RocksDBFilterPolicy.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBFilterPolicy : NSObject

+ (instancetype)bloomFilterPolicyWithBitsPerKey:(int)bitsPerKey;
+ (instancetype)bloomFilterPolicyWithBitsPerKey:(int)bitsPerKey useBlockBasedBuilde:(BOOL)useBlockBasedBuilder;

@end
