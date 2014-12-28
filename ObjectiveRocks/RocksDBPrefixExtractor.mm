//
//  RocksDBPrefixExtractor.m
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBPrefixExtractor.h"
#import "RocksDBOptions.h"
#import "RocksDBSlice.h"
#import "RocksDBCallbackSliceTransform.h"

#import <rocksdb/slice_transform.h>
#import <rocksdb/slice.h>

@interface RocksDBPrefixExtractor ()
{
	RocksDBOptions *_options;
	NSString *_name;
	const rocksdb::SliceTransform *_sliceTransform;

	id (^ _transformBlock)(id key);
	BOOL (^ _prefixCandidateBlock)(id key);
	BOOL (^ _validPrefixBlock)(id prefix);
}
@property (nonatomic, strong) RocksDBOptions *options;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) const rocksdb::SliceTransform *sliceTransform;
@end

@implementation RocksDBPrefixExtractor
@synthesize options = _options;
@synthesize name = _name;
@synthesize sliceTransform = _sliceTransform;

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
			  transformBlock:(id (^)(id key))transformBlock
		prefixCandidateBlock:(BOOL (^)(id key))prefixCandidateBlock
			validPrefixBlock:(BOOL (^)(id prefix))validPrefixBlock
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

rocksdb::Slice trampolineTransform(void* instance, const rocksdb::Slice& src)
{
	NSData *data = [(__bridge id)instance transformKey:src];
	return SliceFromData(data);
}

- (NSData *)transformKey:(const rocksdb::Slice &)keySlice
{
	id key = DecodeKeySlice(keySlice, _options, nil);
	id transformed = _transformBlock(key);
	return EncodeKey(transformed, _options, nil);
}

bool trampolineInDomain(void* instance, const rocksdb::Slice& src)
{
	return [(__bridge id)instance isKeyPrefixCandidate:src];
}

- (BOOL)isKeyPrefixCandidate:(const rocksdb::Slice &)keySlice
{
	id key = DecodeKeySlice(keySlice, _options, nil);
	return _prefixCandidateBlock(key);
}

bool trampolineInRange(void* instance, const rocksdb::Slice& dst)
{
	return [(__bridge id)instance isPrefixValid:dst];
}

- (BOOL)isPrefixValid:(const rocksdb::Slice &)prefixSlice
{
	id prefix = DecodeKeySlice(prefixSlice, _options, nil);
	return _prefixCandidateBlock(prefix);
}

@end
