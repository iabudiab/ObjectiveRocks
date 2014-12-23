//
//  RocksDBComparator.m
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBComparator.h"
#import "RocksDBOptions.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackComparator.h"

#import <rocksdb/comparator.h>
#include <rocksdb/slice.h>

@interface RocksDBComparator ()
{
	RocksDBOptions *_options;
	NSString *_name;
	int (^_comparatorBlock)(id data1, id data2);
	const rocksdb::Comparator *_comparator;
}
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@implementation RocksDBComparator
@synthesize options = _options;
@synthesize comparator = _comparator;

+ (instancetype)comaparatorWithName:(NSString *)name andBlock:(int (^)(id key1, id key2))block
{
	return [[self alloc] initWithName:name andBlock:block];
}

- (instancetype)initWithName:(NSString *)name andBlock:(int (^)(id key1, id key2))block
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_comparatorBlock = [block copy];
		_comparator = RocksDBCallbackComparator((__bridge void *)self, name.UTF8String, &trampoline);
	}
	return self;
}

- (int)compare:(const rocksdb::Slice &)slice1 with:(const rocksdb::Slice &)slice2
{
	id key1 = DecodeKeySlice(slice1, _options, nil);
	id key2 = DecodeKeySlice(slice2, _options, nil);
	return _comparatorBlock ? _comparatorBlock(key1, key2) : 0;
}

int trampoline(void* instance, const rocksdb::Slice& slice1, const rocksdb::Slice& slice2)
{
	return [(__bridge id)instance compare:slice1 with:slice2];
}

@end
