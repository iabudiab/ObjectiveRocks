//
//  RocksDBComparator.m
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBComparator.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackComparator.h"

#import <rocksdb/comparator.h>
#include <rocksdb/slice.h>

@interface RocksDBComparator ()
{
	NSString *_name;
	int (^_comparatorBlock)(NSData *key1, NSData *key2);
	const rocksdb::Comparator *_comparator;
}
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@implementation RocksDBComparator
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
			return [[self alloc] initWithName:@"objectiverocks.string.compare.asc" andBlock:^int(NSData *key1, NSData *key2) {
				NSString *str1 = [[NSString alloc] initWithData:key1 encoding:NSUTF8StringEncoding];
				NSString *str2 = [[NSString alloc] initWithData:key2 encoding:NSUTF8StringEncoding];
				return [str1 compare:str2];
			}];

		case RocksDBComparatorStringCompareDescending:
			return [[self alloc] initWithName:@"objectiverocks.string.compare.desc" andBlock:^int(NSData *key1, NSData *key2) {
				NSString *str1 = [[NSString alloc] initWithData:key1 encoding:NSUTF8StringEncoding];
				NSString *str2 = [[NSString alloc] initWithData:key2 encoding:NSUTF8StringEncoding];
				return -1 * [str1 compare:str2];
			}];
	}
}

#pragma mark - Lifecycle

- (instancetype)initWithName:(NSString *)name
					andBlock:(int (^)(NSData *key1, NSData *key2))block
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
	NSData *key1 = DataFromSlice(slice1);
	NSData *key2 = DataFromSlice(slice2);
	return _comparatorBlock ? _comparatorBlock(key1, key2) : 0;
}

int trampoline(void* instance, const rocksdb::Slice& slice1, const rocksdb::Slice& slice2)
{
	return [(__bridge id)instance compare:slice1 with:slice2];
}

@end
