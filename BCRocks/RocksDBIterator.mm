//
//  RocksDBIterator.m
//  BCRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBIterator.h"

#import <rocksdb/iterator.h>

@interface RocksDBIterator ()
{
	rocksdb::Iterator *_iterator;
}
@end

@implementation RocksDBIterator

#pragma mark - Lifecycle

- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator
{
	self = [super init];
	if (self) {
		_iterator = iterator;
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
		if (_iterator != NULL) {
			delete _iterator;
			_iterator = NULL;
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

- (void)seekToKey:(NSData *)aKey
{
	_iterator->Seek(rocksdb::Slice((char *)aKey.bytes, aKey.length));
}

- (void)next
{
	_iterator->Next();
}

- (void)previous
{
	_iterator->Prev();
}

- (NSData *)key
{
	rocksdb::Slice keySlice = _iterator->key();
	return [NSData dataWithBytes:keySlice.data() length:keySlice.size()];
}

- (NSData *)value
{
	rocksdb::Slice valueSlice = _iterator->value();
	return [NSData dataWithBytes:valueSlice.data() length:valueSlice.size()];
}

#pragma mark - Enumeration

- (void)enumerateKeysUsingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysInReverse:NO usingBlock:block];
}

- (void)enumerateKeysInReverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block
{
	[self enumerateKeysInRange:RocksMakeRange(nil, nil) reverse:reverse usingBlock:block];
}

- (void)enumerateKeysInRange:(RocksDBIteratorRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block
{
	BOOL stop = NO;

	if (range.start != nil) {
		[self seekToKey:range.start];
	} else {
		reverse ? _iterator->SeekToLast(): _iterator->SeekToFirst();
	}

	rocksdb::Slice limitSlice;
	if (range.end != nil) {
		limitSlice = rocksdb::Slice((char *)range.end.bytes, range.end.length);
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

		NSData *key = [NSData dataWithBytes:keySlice.data() length:keySlice.size()];
		if (block) block(key, &stop);

		if (stop == YES) break;

		reverse ? _iterator->Prev(): _iterator->Next();
	}
}

@end
