//
//  RocksDBPrefixExtractor.m
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBPrefixExtractor.h"
#import "RocksDBOptions.h"

#import <rocksdb/slice_transform.h>

@interface RocksDBPrefixExtractor ()
{
	RocksDBOptions *_options;
	NSString *_name;
	rocksdb::SliceTransform *_sliceTransform;
}
@end

@implementation RocksDBPrefixExtractor


@end
