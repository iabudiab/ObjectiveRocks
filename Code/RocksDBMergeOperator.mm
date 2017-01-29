//
//  RocksDBMergeOperator.m
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBMergeOperator.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackAssociativeMergeOperator.h"
#import "RocksDBCallbackMergeOperator.h"

#import <rocksdb/slice.h>
#import <Rocksdb/env.h>

#pragma mark - Extension

@interface RocksDBMergeOperator ()
{
	NSString *_name;
	rocksdb::MergeOperator *_mergeOperator;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

#pragma mark - Associative Merge Operator

@interface RocksDBAssociativeMergeOperator : RocksDBMergeOperator
{
	NSData * (^ _associativeMergeBlock)(NSData *, NSData *existingValue, NSData *value);
}
@end

@implementation RocksDBAssociativeMergeOperator

- (instancetype)initWithName:(NSString *)name andBlock:(NSData * (^)(NSData *, NSData *, NSData *))block
{
	self = [super init];
	if (self) {
		self.name = name;
		self.mergeOperator = RocksDBCallbackAssociativeMergeOperator((__bridge void *)self, name.UTF8String, &trampoline);
		_associativeMergeBlock = [block copy];
	}
	return self;
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
	new_value->clear();
	new_value->assign((char *)data.bytes, data.length);
	return true;
}

- (NSData *)mergeForKey:(const rocksdb::Slice &)keySlice
	  withExistingValue:(const rocksdb::Slice *)existingSlice
			   andValue:(const rocksdb::Slice &)valueSlice
{
	NSData *key = DataFromSlice(keySlice);
	NSData *previous = (existingSlice == nullptr) ? nil : DataFromSlice(*existingSlice);
	NSData *value = DataFromSlice(valueSlice);

	NSData *mergeResult = _associativeMergeBlock ? _associativeMergeBlock(key, previous, value): nil;
	return mergeResult;
}

@end

#pragma mark - Generic Merge Operator

@interface RocksDBGenericMergeOperator : RocksDBMergeOperator
{
	NSData * (^ _partialMergeBlock)(NSData * key, NSData *leftOperand, NSData *rightOperand);
	NSData * (^ _fullMergeBlock)(NSData * key, NSData * existingValue, NSArray<NSData *> *operandList);
}
@end

@implementation RocksDBGenericMergeOperator

- (instancetype)initWithName:(NSString *)name
		   partialMergeBlock:(NSData * (^)(NSData *key, NSData *leftOperand, NSData *rightOperand))partialMergeBlock
			  fullMergeBlock:(NSData * (^)(NSData *key, NSData *existingValue, NSArray<NSData *> *operandList))fullMergeBlock
{
	self = [super init];
	if (self) {
		self.name = name;
		self.mergeOperator = RocksDBCallbackMergeOperator((__bridge void *)self, name.UTF8String, &trampolinePartialMerge, &trampolineFullMerge);
		_partialMergeBlock = [partialMergeBlock copy];
		_fullMergeBlock = [fullMergeBlock copy];
	}
	return self;
}

bool trampolinePartialMerge(void* instance,
							const rocksdb::Slice& key,
							const rocksdb::Slice& left_operand,
							const rocksdb::Slice& right_operand,
							std::string* new_value,
							rocksdb::Logger* logger)
{
	NSData *data = [(__bridge id)instance partialMergeForKey:key
											 withLeftOperand:left_operand
											 andRightOperand:right_operand];
	if (data != nil) {
		new_value->clear();
		new_value->assign((char *)data.bytes, data.length);
		return true;
	}
	return false;
}

- (NSData *)partialMergeForKey:(const rocksdb::Slice &)keySlice
			   withLeftOperand:(const rocksdb::Slice &)leftSlice
			   andRightOperand:(const rocksdb::Slice &)rightSlice
{
	NSData *key = DataFromSlice(keySlice);
	NSData *left = DataFromSlice(leftSlice);
	NSData *right = DataFromSlice(rightSlice);

	NSData *mergeResult = _partialMergeBlock ? _partialMergeBlock(key, left, right): nil;
	return mergeResult;
}

bool trampolineFullMerge(void* instance,
						 const rocksdb::Slice& key,
						 const rocksdb::Slice* existing_value,
						 const std::deque<std::string>& operand_list,
						 std::string* new_value,
						 rocksdb::Logger* logger)
{
	NSData *data = [(__bridge id)instance fullMergeForKey:key
										withExistingValue:existing_value
										   andOperandList:operand_list];

	if (data != nil) {
		new_value->clear();
		new_value->assign((char *)data.bytes, data.length);
		return true;
	}
	return false;
}

- (NSData *)fullMergeForKey:(const rocksdb::Slice &)keySlice
		  withExistingValue:(const rocksdb::Slice *)existingSlice
			 andOperandList:(const std::deque<std::string> &)operand_list
{
	NSData *key = DataFromSlice(keySlice);
	NSData *previous = (existingSlice == nullptr) ? nil : DataFromSlice(*existingSlice);

	NSMutableArray *operands = [NSMutableArray arrayWithCapacity:operand_list.size()];

	for (const auto &value : operand_list) {
		NSData *data = DataFromSlice(rocksdb::Slice(value));
		if (data != nil) {
			[operands addObject:data];
		}
	}

	NSData *mergeResult = _fullMergeBlock ? _fullMergeBlock(key, previous, operands) : nil;
	return mergeResult;
}

@end

#pragma mark - Merge Operator Factory

@implementation RocksDBMergeOperator
@synthesize name = _name;
@synthesize mergeOperator = _mergeOperator;

+ (instancetype)operatorWithName:(NSString *)name andBlock:(NSData * (^)(NSData *, NSData *, NSData *))block
{
	return [[RocksDBAssociativeMergeOperator alloc] initWithName:name andBlock:block];
}

+ (instancetype)operatorWithName:(NSString *)name
			   partialMergeBlock:(NSData * (^)(NSData * key, NSData *leftOperand, NSData *rightOperand))partialMergeBlock
				  fullMergeBlock:(NSData * (^)(NSData *key, NSData *existingValue, NSArray<NSData *> *operandList))fullMergeBlock
{
	return [[RocksDBGenericMergeOperator alloc] initWithName:name partialMergeBlock:partialMergeBlock fullMergeBlock:fullMergeBlock];
}

@end
