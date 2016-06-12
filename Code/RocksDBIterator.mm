//
//  RocksDBIterator.m
//  ObjectiveRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBIterator.h"
#import "RocksDBSlice.h"

#import <rocksdb/iterator.h>

#pragma mark - Iterator

@interface RocksDBIterator ()
{
	rocksdb::Iterator *_iterator;
	RocksDBEncodingOptions *_options;
}
@end

@implementation RocksDBIterator

#pragma mark - Lifecycle

- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator
				andEncodingOptions:(RocksDBEncodingOptions *)options
{
	self = [super init];
	if (self) {
		_iterator = iterator;
		_options = options;
	}
	return self;
}

- (void)dealloc
{
	[self close];
}

- (void)close
{
	@synchronized(self) {
		if (_iterator != nullptr) {
			delete _iterator;
			_iterator = nullptr;
		}
	}
}

#pragma mark - Operations

- (BOOL)isValid
{
	return _iterator->Valid();
}

- (void)seekToFirst
{
	_iterator->SeekToFirst();
}

- (void)seekToLast
{
	_iterator->SeekToLast();
}

- (void)seekToKey:(id)aKey
{
	if (aKey != nil) {
		_iterator->Seek(SliceFromKey(aKey, _options, nil));
	}
}

- (void)next
{
	_iterator->Next();
}

- (void)previous
{
	_iterator->Prev();
}

- (id)key
{
	rocksdb::Slice keySlice = _iterator->key();
	id key = DecodeKeySlice(keySlice, _options, nil);
	return key;
}

- (id)value
{
	rocksdb::Slice valueSlice = _iterator->value();
	id value = DecodeValueSlice(self.key, valueSlice, _options, nil);
	return value;
}

#pragma mark - Enumerate Keys

- (void)enumerateKeysUsingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:NO usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysInReverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:reverse usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysInRange:(RocksDBKeyRange *)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:range reverse:reverse usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

#pragma mark - Enumerate Keys & Values

- (void)enumerateKeysAndValuesUsingBlock:(void (^)(id key, id value, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:NO usingBlock:block];
}

- (void)enumerateKeysAndValuesInReverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:reverse usingBlock:block];
}

- (void)enumerateKeysAndValuesInRange:(RocksDBKeyRange *)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block
{
	BOOL stop = NO;

	if (range.start != nil) {
		[self seekToKey:range.start];
	} else {
		reverse ? _iterator->SeekToLast(): _iterator->SeekToFirst();
	}

	rocksdb::Slice limitSlice;
	if (range.end != nil) {
		limitSlice = SliceFromKey(range.end, _options, nil);
	}

	BOOL (^ checkLimit)(BOOL, rocksdb::Slice) = ^ BOOL (BOOL reverse, rocksdb::Slice key) {
		if (limitSlice.size() == 0) return YES;

		if (reverse && key.ToString() <= limitSlice.ToString()) return NO;
		if (!reverse && key.ToString() >= limitSlice.ToString()) return NO;

		return YES;
	};

	while (_iterator->Valid() && checkLimit(reverse, _iterator->key())) {
		if (block) block(self.key, self.value, &stop);
		if (stop == YES) break;

		reverse ? _iterator->Prev(): _iterator->Next();
	}
}

#pragma mark - Enumerate Prefix

- (void)enumerateKeysWithPrefix:(id)prefix usingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysAndValuesWithPrefix:prefix usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysAndValuesWithPrefix:(id)prefix usingBlock:(void (^)(id key, id value, BOOL *stop))block
{
	BOOL stop = NO;

	rocksdb::Slice prefixSlice = SliceFromKey(prefix, _options, nil);

	for (_iterator->Seek(prefixSlice); _iterator->Valid(); _iterator->Next()) {
		if (_iterator->key().starts_with(prefixSlice) == false) continue;
		if (block) block(self.key, self.value, &stop);
		if (stop == YES) break;
	}
}

@end
