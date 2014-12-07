//
//  RocksDBComparator.m
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBComparator.h"
#import "RocksDBCallbackComparator.h"

#import <rocksdb/comparator.h>
#include <rocksdb/slice.h>

@interface RocksDBComparator ()
{
	NSString *_name;
	int (^_comparatorBlock)(NSData *data1, NSData *data2);
	const rocksdb::Comparator *_comparator;
}
@property (readonly, assign) const rocksdb::Comparator *comparator;
@end

@implementation RocksDBComparator
@synthesize comparator = _comparator;

+ (instancetype)comaparatorWithName:(NSString *)name andBlock:(int (^)(NSData *data1, NSData *data2))block
{
	return [[RocksDBComparator alloc] initWithName:name andBlock:block];
}

- (instancetype)initWithName:(NSString *)name andBlock:(int (^)(NSData *data1, NSData *data2))block
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_comparatorBlock = [block copy];
		_comparator = RocksDBCallbackComparator((__bridge void *)self, name.UTF8String, &trampoline);
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
