//
//  RocksDBIterator.m
//  ObjectiveRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBIterator.h"
#import "RocksDBSlice.h"
#import "RocksDBError.h"

#import <rocksdb/iterator.h>

#pragma mark - Iterator

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

- (void)seekToKey:(NSData *)aKey
{
	if (aKey != nil) {
		_iterator->Seek(SliceFromData(aKey));
	}
}

- (void)seekForPrev:(NSData *)aKey
{
	if (aKey != nil) {
		_iterator->SeekForPrev(SliceFromData(aKey));
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

- (NSData *)key
{
	rocksdb::Slice keySlice = _iterator->key();
	NSData *key = [NSData dataWithBytesNoCopy:(void*)keySlice.data()
					   length:keySlice.size()
				     freeWhenDone:NO];
	return key;
}

- (NSData *)value
{
	rocksdb::Slice valueSlice = _iterator->value();
	NSData *value = [NSData dataWithBytesNoCopy:(void*)valueSlice.data()
					     length:valueSlice.size()
				       freeWhenDone:NO];
	return value;
}

- (void)status:(NSError * __autoreleasing *)error
{
    rocksdb::Status status = _iterator->status();

    if (!status.ok()) {
        NSError *temp = [RocksDBError errorWithRocksStatus:status];
        if (error && *error == nil) {
            *error = temp;
        }
    }
}

#pragma mark - Enumerate Keys

- (void)enumerateKeysUsingBlock:(void (^)(NSData *key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:NO usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysInReverse:(BOOL)reverse
					usingBlock:(void (^)(NSData *key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:reverse usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysInRange:(RocksDBKeyRange *)range
					 reverse:(BOOL)reverse
				  usingBlock:(void (^)(NSData *key, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:range reverse:reverse usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
		block(key, stop);
	}];
}

#pragma mark - Enumerate Keys & Values

- (void)enumerateKeysAndValuesUsingBlock:(void (^)(NSData *key, NSData *value, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:NO usingBlock:block];
}

- (void)enumerateKeysAndValuesInReverse:(BOOL)reverse
							 usingBlock:(void (^)(NSData *key, NSData *value, BOOL *stop))block
{
	[self enumerateKeysAndValuesInRange:RocksDBOpenRange reverse:reverse usingBlock:block];
}

- (void)enumerateKeysAndValuesInRange:(RocksDBKeyRange *)range
							  reverse:(BOOL)reverse
						   usingBlock:(void (^)(NSData *key, NSData *value, BOOL *stop))block
{
	@autoreleasepool {
		BOOL stop = NO;

		if (range.start != nil) {
			[self seekToKey:range.start];
		} else {
			reverse ? _iterator->SeekToLast(): _iterator->SeekToFirst();
		}

		rocksdb::Slice limitSlice;
		if (range.end != nil) {
			limitSlice = SliceFromData(range.end);
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
}

#pragma mark - Enumerate Prefix

- (void)enumerateKeysWithPrefix:(NSData *)prefix usingBlock:(void (^)(NSData *key, BOOL *stop))block
{
	[self enumerateKeysAndValuesWithPrefix:prefix usingBlock:^(NSData *key, NSData *value, BOOL *stop) {
		block(key, stop);
	}];
}

- (void)enumerateKeysAndValuesWithPrefix:(NSData *)prefix
							  usingBlock:(void (^)(NSData *key, NSData *value, BOOL *stop))block
{
	@autoreleasepool {
		BOOL stop = NO;
		rocksdb::Slice prefixSlice = SliceFromData(prefix);

		for (_iterator->Seek(prefixSlice); _iterator->Valid(); _iterator->Next()) {
			if (_iterator->key().starts_with(prefixSlice) == false) continue;
			if (block) block(self.key, self.value, &stop);
			if (stop == YES) break;
		}
	}
}

@end
