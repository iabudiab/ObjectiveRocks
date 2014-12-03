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
	[self enumerateKeysWithOptions:0 usingBlock:block];
}

- (void)enumerateKeysWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(id key, BOOL *stop))block
{
	BOOL stop = NO;

	for (_iterator->SeekToFirst(); _iterator->Valid(); _iterator->Next()) {
		rocksdb::Slice keySlice = _iterator->key();
		NSData *key = [NSData dataWithBytes:keySlice.data() length:keySlice.size()];

		if (block) block(key, &stop);
		if (stop == YES) break;
	}
	rocksdb::Status status = _iterator->status();
	if (!status.ok()) {

	}
}

@end
