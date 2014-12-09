//
//  RocksDBMergeOperator.m
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBMergeOperator.h"
#import "RocksDBCallbackAssociativeMergeOperator.h"

#import <rocksdb/slice.h>
#import <Rocksdb/env.h>

@interface RocksDBMergeOperator ()
{
	NSString *_name;
	NSData * (^ _mergeBlock)(NSData *key, NSData *existingValue, NSData *value);
	rocksdb::MergeOperator *_mergeOperator;
}
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

@implementation RocksDBMergeOperator
@synthesize mergeOperator = _mergeOperator;

+ (instancetype)operatorWithName:(NSString *)name andBlock:(NSData *(^)(NSData *, NSData *, NSData *))block
{
	return [[self alloc] initWithName:name andBlock:block];
}

- (instancetype)initWithName:(NSString *)name andBlock:(NSData *(^)(NSData *, NSData *, NSData *))block
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_mergeBlock = [block copy];
		_mergeOperator = RocksDBCallbackAssociativeMergeOperator((__bridge void *)self, name.UTF8String, &trampoline);
	}
	return self;
}

- (NSData *)mergeForKey:(NSData *)key withExistingValue:(NSData *)existing andValue:(NSData *)value
{
	return _mergeBlock ? _mergeBlock(key, existing, value) : nil;
}

bool trampoline(void* instance,
				const rocksdb::Slice& key,
				const rocksdb::Slice* existing_value,
				const rocksdb::Slice& value,
				std::string* new_value,
				rocksdb::Logger* logger)
{
	NSData *keyData = [NSData dataWithBytes:key.data() length:key.size()];

	NSData *existingData = (existing_value == nullptr) ? nil : [NSData dataWithBytes:existing_value->data() length:existing_value->size()];
	NSData *valueData = [NSData dataWithBytes:value.data() length:value.size()];

	NSData *result = [(__bridge id)instance mergeForKey:keyData
									  withExistingValue:existingData
											   andValue:valueData];
	*new_value = (char *)result.bytes;
	return true;
}

@end
