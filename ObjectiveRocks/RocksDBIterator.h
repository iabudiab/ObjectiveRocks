//
//  RocksDBIterator.h
//  ObjectiveRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _RocksDBIteratorRange
{
	NSData *start;
	NSData *end;
} RocksDBIteratorRange;

NS_INLINE RocksDBIteratorRange RocksMakeRange(NSData *start, NSData *end) {
	RocksDBIteratorRange range;
	range.start = start;
	range.end = end;
	return range;
}

namespace rocksdb {
	class Iterator;
}

@interface RocksDBIterator : NSObject

- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator;
- (void)close;

- (BOOL)isValid;
- (void)seekToFirst;
- (void)seekToLast;
- (void)seekToKey:(NSData *)aKey;
- (void)next;
- (void)previous;
- (NSData *)key;
- (NSData *)value;

- (void)enumerateKeysUsingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysInReverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysInRange:(RocksDBIteratorRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;

@end
