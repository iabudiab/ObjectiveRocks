//
//  RocksDBComparator.m
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBComparator.h"
#import "RocksDBEncodingOptions.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackComparator.h"

#import <rocksdb/comparator.h>
#include <rocksdb/slice.h>

@interface RocksDBComparator ()
{
	RocksDBEncodingOptions *_encodingOptions;
	NSString *_name;
	int (^_comparatorBlock)(id data1, id data2);
	const rocksdb::Comparator *_comparator;
}
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@implementation RocksDBComparator
@synthesize encodingOptions = _encodingOptions;
@synthesize name = _name;
@synthesize comparator = _comparator;

#pragma mark - Comparator Factory

+ (instancetype)comaparatorWithType:(RocksDBComparatorType)type
{
	switch (type) {
		case RocksDBComparatorBytewiseAscending:
			return [[self alloc] initWithNativeComparator:rocksdb::BytewiseComparator()];

		case RocksDBComparatorBytewiseDescending:
			return [[self alloc] initWithNativeComparator:rocksdb::ReverseBytewiseComparator()];

		case RocksDBComparatorStringCompareAscending:
			return [[self alloc] initWithName:@"objectiverocks.string.compare.asc" andBlock:^int(id key1, id key2) {
				return [key1 compare:key2];
			}];

		case RocksDBComparatorStringCompareDescending:
			return [[self alloc] initWithName:@"objectiverocks.string.compare.desc" andBlock:^int(id key1, id key2) {
				return -1 * [key1 compare:key2];
			}];

		case RocksDBComparatorNumberAscending:
			return [[self alloc] initWithName:@"objectiverocks.key.length.asc" andBlock:^int(id key1, id key2) {
				return [key1 compare:key2];
			}];

		case RocksDBComparatorNumberDescending:
			return [[self alloc] initWithName:@"objectiverocks.key.length.desc" andBlock:^int(id key1, id key2) {
				return [key1 compare:key2] * -1;
			}];
	}
}

#pragma mark - Lifecycle

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

- (instancetype)initWithNativeComparator:(const rocksdb::Comparator *)comparator
{
	self = [super init];
	if (self) {
		_name = [NSString stringWithCString:comparator->Name() encoding:NSUTF8StringEncoding];
		_comparator = comparator;
	}
	return self;
}

#pragma mark - Callback

- (int)compare:(const rocksdb::Slice &)slice1 with:(const rocksdb::Slice &)slice2
{
	id key1 = DecodeKeySlice(slice1, _encodingOptions, nil);
	id key2 = DecodeKeySlice(slice2, _encodingOptions, nil);
	return _comparatorBlock ? _comparatorBlock(key1, key2) : 0;
}

int trampoline(void* instance, const rocksdb::Slice& slice1, const rocksdb::Slice& slice2)
{
	return [(__bridge id)instance compare:slice1 with:slice2];
}

@end
