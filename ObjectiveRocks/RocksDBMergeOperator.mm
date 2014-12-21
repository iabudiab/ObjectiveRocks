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
#import "RocksDBCallbackMergeOperator.h"

#import <rocksdb/slice.h>
#import <Rocksdb/env.h>

#pragma mark - Extension

@interface RocksDBMergeOperator ()
{
	RocksDBOptions *_options;
	NSString *_name;
	rocksdb::MergeOperator *_mergeOperator;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

#pragma mark - Associative Merge Operator

@interface RocksDBAssociativeMergeOperator : RocksDBMergeOperator
{
	id (^ _associativeMergeBlock)(id, id existingValue, id value);
}
@end

@implementation RocksDBAssociativeMergeOperator

- (instancetype)initWithName:(NSString *)name andBlock:(id (^)(id, id, id))block
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
	*new_value = (char *)data.bytes;
	return true;
}

- (NSData *)mergeForKey:(const rocksdb::Slice &)keySlice
	  withExistingValue:(const rocksdb::Slice *)existingSlice
			   andValue:(const rocksdb::Slice &)valueSlice
{
	id key = DecodeKeySlice(keySlice, self.options, nil);
	id previous = (existingSlice == nullptr) ? nil : DecodeValueSlice(key, *existingSlice, self.options, nil);
	id value = DecodeValueSlice(key, valueSlice, self.options, nil);

	id mergeResult = _associativeMergeBlock ? _associativeMergeBlock(key, previous, value): nil;

	return EncodeValue(key, mergeResult, self.options, nil);
}

@end

#pragma mark - Generic Merge Operator

@interface RocksDBGenericMergeOperator : RocksDBMergeOperator
{
	NSString * (^ _partialMergeBlock)(id key, NSString *leftOperand, NSString *rightOperand);
	id (^ _fullMergeBlock)(id key, id existingValue, NSArray *operandList);
}
@end

@implementation RocksDBGenericMergeOperator

- (instancetype)initWithName:(NSString *)name
		   partialMergeBlock:(NSString * (^)(id key, NSString *leftOperand, NSString *rightOperand))partialMergeBlock
			  fullMergeBlock:(id (^)(id key, id existingValue, NSArray *operandList))fullMergeBlock
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
	id key = DecodeKeySlice(keySlice, self.options, nil);
	id left = DecodeValueSlice(key, leftSlice, self.options, nil);
	id right = DecodeValueSlice(key, rightSlice, self.options, nil);

	NSString * mergeResult = _partialMergeBlock ? _partialMergeBlock(key, left, right): nil;

	return [mergeResult dataUsingEncoding:NSUTF8StringEncoding];
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
	id key = DecodeKeySlice(keySlice, self.options, nil);
	id previous = (existingSlice == nullptr) ? nil : DecodeValueSlice(key, *existingSlice, self.options, nil);

	NSMutableArray *operands = [NSMutableArray arrayWithCapacity:operand_list.size()];

	for (const auto &value : operand_list) {
		id decoded = [NSString stringWithCString:value.c_str() encoding:NSUTF8StringEncoding];
		if (decoded != nil) {
			[operands addObject:decoded];
		}
	}

	id mergeResult = _fullMergeBlock ? _fullMergeBlock(key, previous, operands) : nil;

	return EncodeValue(key, mergeResult, self.options, nil);;
}

@end

#pragma mark - Merge Operator Factory

@implementation RocksDBMergeOperator
@synthesize name = _name;
@synthesize options = _options;
@synthesize mergeOperator = _mergeOperator;

+ (instancetype)operatorWithName:(NSString *)name andBlock:(id (^)(id, id, id))block
{
	return [[RocksDBAssociativeMergeOperator alloc] initWithName:name andBlock:block];
}

+ (instancetype)operatorWithName:(NSString *)name
			   partialMergeBlock:(NSString * (^)(id key, NSString *leftOperand, NSString *rightOperand))partialMergeBlock
				  fullMergeBlock:(id (^)(id key, id existingValue, NSArray *operandList))fullMergeBlock
{
	return [[RocksDBGenericMergeOperator alloc] initWithName:name partialMergeBlock:partialMergeBlock fullMergeBlock:fullMergeBlock];
}

@end
