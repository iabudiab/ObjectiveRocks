//
//  RocksDBComparator.m
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBComparator.h"
#import "RocksDBCallbackComparator.h"

#import <objc/runtime.h>

#import <rocksdb/comparator.h>
#include <rocksdb/slice.h>

@interface RocksDBComparator ()
{
	int (^_comparatorBlock)(NSData *data1, NSData *data2);
	const rocksdb::Comparator *_comparator;
}
@end

@implementation RocksDBComparator
@synthesize comparator = _comparator;

- (instancetype)initWithBlock:(int (^)(NSData *data1, NSData *data2))block
{
	self = [super init];
	if (self) {
		_comparatorBlock = [block copy];
		_comparator = RocksDBCallbackComparator((__bridge void *)self, &trampoline);
	}
	return self;
}

- (int)compare:(NSData *)data1 with:(NSData *)data2
{
	return _comparatorBlock ? _comparatorBlock(data1, data2) : 0;
}

int trampoline(void* instance, const rocksdb::Slice& slice1, const rocksdb::Slice& slice2)
{
	NSData *data1 = [NSData dataWithBytes:slice1.data() length:slice1.size()];
	NSData *data2 = [NSData dataWithBytes:slice2.data() length:slice2.size()];

	return [(__bridge id)instance compare:data1 with:data2];
}

@end
