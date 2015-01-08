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

static RocksDBIteratorKeyRange RocksDBEmptyRange = RocksDBMakeKeyRange(nil, nil);

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
	[self enumerateKeysAndValuesInRange:RocksDBEmptyRange reverse:NO usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysInReverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBEmptyRange reverse:reverse usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysInRange:(RocksDBIteratorKeyRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:range reverse:reverse usingBlock:^(id key, id value, BOOL *stop) {
		block(key, stop);
	}];
}

#pragma mark - Enumerate Keys & Values

- (void)enumerateKeysAndValuesUsingBlock:(void (^)(id key, id value, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBEmptyRange reverse:NO usingBlock:block];
}

- (void)enumerateKeysAndValuesInReverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBEmptyRange reverse:reverse usingBlock:block];
}

- (void)enumerateKeysAndValuesInRange:(RocksDBIteratorKeyRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block
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

	BOOL (^ checkLimit)(BOOL reverse, rocksdb::Slice key) = ^ BOOL (BOOL reverse, rocksdb::Slice key) {
		if (limitSlice.size() == 0) return YES;

		if (reverse && key.ToString() <= limitSlice.ToString()) return NO;
		if (!reverse && key.ToString() >= limitSlice.ToString()) return NO;

		return YES;
	};

	rocksdb::Slice keySlice;
	while (_iterator->Valid() && checkLimit(reverse, keySlice)) {
		keySlice = _iterator->key();

		if (block) block(self.key, self.value, &stop);
		if (stop == YES) break;

		reverse ? _iterator->Prev(): _iterator->Next();
	}
}

- (void)enumerateKeysWithPrefix:(id)prefix usingBlock:(void (^)(id key, BOOL *stop))block
{
	BOOL stop = NO;

	rocksdb::Slice prefixSlice = SliceFromKey(prefix, _options, nil);
	_iterator->Seek(prefixSlice);

	BOOL (^ checkBounds)(rocksdb::Slice key) = ^ BOOL (rocksdb::Slice key) {
		return key.starts_with(prefixSlice);
	};

	rocksdb::Slice keySlice = _iterator->key();

	while (_iterator->Valid() && checkBounds(keySlice)) {
		keySlice = _iterator->key();

		if (block) block(self.key, &stop);
		if (stop == YES) break;

		_iterator->Next();
	}
}

@end
