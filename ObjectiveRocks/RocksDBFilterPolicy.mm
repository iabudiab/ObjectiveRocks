//
//  RocksDBFilterPolicy.m
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBFilterPolicy.h"

#import <rocksdb/filter_policy.h>

@interface RocksDBFilterPolicy ()
{
	const rocksdb::FilterPolicy *_filterPolicy;
}
@property (nonatomic, assign) const rocksdb::FilterPolicy *filterPolicy;
@end

@implementation RocksDBFilterPolicy
@synthesize filterPolicy = _filterPolicy;

+ (instancetype)bloomFilterPolicyWithBitsPerKey:(int)bitsPerKey
{
	return [[RocksDBFilterPolicy alloc] initWithNativeFilterPolicy:rocksdb::NewBloomFilterPolicy(bitsPerKey)];
}

+ (instancetype)bloomFilterPolicyWithBitsPerKey:(int)bitsPerKey useBlockBasedBuilde:(BOOL)useBlockBasedBuilder
{
	return [[RocksDBFilterPolicy alloc] initWithNativeFilterPolicy:rocksdb::NewBloomFilterPolicy(bitsPerKey, useBlockBasedBuilder)];
}

- (instancetype)initWithNativeFilterPolicy:(const rocksdb::FilterPolicy *)filterPolicy
{
	self = [super init];
	if (self) {
		_filterPolicy = filterPolicy;
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_filterPolicy != nullptr) {
			delete _filterPolicy;
			_filterPolicy = nullptr;
		}
	}
}

@end
