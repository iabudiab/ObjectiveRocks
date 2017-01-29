//
//  RocksDBPrefixExtractor.m
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBPrefixExtractor.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackSliceTransform.h"

#import <rocksdb/slice_transform.h>
#import <rocksdb/slice.h>

@interface RocksDBPrefixExtractor ()
{
	NSString *_name;
	const rocksdb::SliceTransform *_sliceTransform;

	NSData * (^ _transformBlock)(NSData *key);
	BOOL (^ _prefixCandidateBlock)(NSData * key);
	BOOL (^ _validPrefixBlock)(NSData *prefix);
}
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) const rocksdb::SliceTransform *sliceTransform;
@end

@implementation RocksDBPrefixExtractor
@synthesize name = _name;
@synthesize sliceTransform = _sliceTransform;

#pragma mark - Lifecycle

+ (instancetype)prefixExtractorWithType:(RocksDBPrefixType)type length:(size_t)length
{
	switch (type) {
		case RocksDBPrefixFixedLength:
			return [[self alloc] initWithNativeSliceTransform:rocksdb::NewFixedPrefixTransform(length)];
	}
}

- (instancetype)initWithNativeSliceTransform:(const rocksdb::SliceTransform *)sliceTransform
{
	self = [super init];
	if (self) {
		_name = [NSString stringWithCString:sliceTransform->Name() encoding:NSUTF8StringEncoding];
		_sliceTransform = sliceTransform;
	}
	return self;
}

- (instancetype)initWithName:(NSString *)name
			  transformBlock:(NSData * (^)(NSData *key))transformBlock
		prefixCandidateBlock:(BOOL (^)(NSData *key))prefixCandidateBlock
			validPrefixBlock:(BOOL (^)(NSData *prefix))validPrefixBlock
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_transformBlock = [transformBlock copy];
		_prefixCandidateBlock = [prefixCandidateBlock copy];
		_validPrefixBlock = [validPrefixBlock copy];
		_sliceTransform = RocksDBCallbackSliceTransform((__bridge void *)self, _name.UTF8String,
														&trampolineTransform, &trampolineInDomain, &trampolineInRange);
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_sliceTransform != nullptr) {
			delete _sliceTransform;
			_sliceTransform = nullptr;
		}
	}
}

#pragma mark - Callbacks

rocksdb::Slice trampolineTransform(void* instance, const rocksdb::Slice& src)
{
	NSData *data = [(__bridge id)instance transformKey:src];
	return SliceFromData(data);
}

- (NSData *)transformKey:(const rocksdb::Slice &)keySlice
{
	NSData *key = DataFromSlice(keySlice);
	NSData * transformed = _transformBlock(key);
	return transformed;
}

bool trampolineInDomain(void* instance, const rocksdb::Slice& src)
{
	return [(__bridge id)instance isKeyPrefixCandidate:src];
}

- (BOOL)isKeyPrefixCandidate:(const rocksdb::Slice &)keySlice
{
	NSData *key = DataFromSlice(keySlice);
	return _prefixCandidateBlock(key);
}

bool trampolineInRange(void* instance, const rocksdb::Slice& dst)
{
	return [(__bridge id)instance isPrefixValid:dst];
}

- (BOOL)isPrefixValid:(const rocksdb::Slice &)prefixSlice
{
	NSData *prefix = DataFromSlice(prefixSlice);
	return _validPrefixBlock(prefix);
}

@end
