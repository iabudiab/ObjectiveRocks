//
//  RocksDBMergeOperator.m
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBMergeOperator.h"
#import "RocksDBOptions.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackAssociativeMergeOperator.h"

#import <rocksdb/slice.h>
#import <Rocksdb/env.h>

@interface RocksDBMergeOperator ()
{
	RocksDBOptions *_options;
	NSString *_name;
	id (^ _mergeBlock)(id, id existingValue, id value);
	rocksdb::MergeOperator *_mergeOperator;
}
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

@implementation RocksDBMergeOperator
@synthesize options = _options;
@synthesize mergeOperator = _mergeOperator;

+ (instancetype)operatorWithName:(NSString *)name andBlock:(id (^)(id, id, id))block
{
	return [[self alloc] initWithName:name andBlock:block];
}

- (instancetype)initWithName:(NSString *)name andBlock:(id (^)(id, id, id))block
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_mergeBlock = [block copy];
		_mergeOperator = RocksDBCallbackAssociativeMergeOperator((__bridge void *)self, name.UTF8String, &trampoline);
	}
	return self;
}

- (NSData *)mergeForKey:(const rocksdb::Slice &)keySlice
withExistingValue:(const rocksdb::Slice *)existingSlice
		 andValue:(const rocksdb::Slice &)valueSlice
{
	id key = DecodeKeySlice(keySlice, _options, nil);
	id previous = (existingSlice == nullptr) ? nil : DecodeValueSlice(key, *existingSlice, _options, nil);
	id value = DecodeValueSlice(key, valueSlice, _options, nil);

	id mergeResult = _mergeBlock ? _mergeBlock(key, previous, value): nil;

	return EncodeValue(key, mergeResult, _options, nil);
}

bool trampoline(void* instance,
				const rocksdb::Slice& key,
				const rocksdb::Slice* existing_value,
				const rocksdb::Slice& value,
				std::string* new_value,
				rocksdb::Logger* logger)
{
	NSData *data = [(__bridge id)instance mergeForKey:key
									withExistingValue:existing_value
											 andValue:value];
	*new_value = (char *)data.bytes;
	return true;
}

@end
