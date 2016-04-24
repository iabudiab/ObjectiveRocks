//
//  RocksDBCompactRangeOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 24/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "RocksDBCompactRangeOptions.h"

#import <rocksdb/options.h>

@interface RocksDBCompactRangeOptions ()
{
	rocksdb::CompactRangeOptions _options;
}
@end

@implementation RocksDBCompactRangeOptions

@end
