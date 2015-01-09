//
//  RocksDBIterator.h
//  ObjectiveRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBEncodingOptions.h"

typedef struct RocksDBIteratorKeyRange
{
	id start;
	id end;
} RocksDBIteratorKeyRange;

NS_INLINE RocksDBIteratorKeyRange RocksDBMakeKeyRange(id start, id end) {
	RocksDBIteratorKeyRange range = (RocksDBIteratorKeyRange) {
		.start = start,
		.end = end
	};
	return range;
}

namespace rocksdb {
	class Iterator;
}

@interface RocksDBIterator : NSObject

- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator
				andEncodingOptions:(RocksDBEncodingOptions *)options;
- (void)close;

- (BOOL)isValid;
- (void)seekToFirst;
- (void)seekToLast;
- (void)seekToKey:(id)aKey;
- (void)next;
- (void)previous;
- (id)key;
- (id)value;

- (void)enumerateKeysUsingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysInReverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysInRange:(RocksDBIteratorKeyRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;

- (void)enumerateKeysAndValuesUsingBlock:(void (^)(id key, id value, BOOL *stop))block;
- (void)enumerateKeysAndValuesInReverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block;
- (void)enumerateKeysAndValuesInRange:(RocksDBIteratorKeyRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block;

- (void)enumerateKeysWithPrefix:(id)prefix usingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysAndValuesWithPrefix:(id)prefix usingBlock:(void (^)(id key, id value, BOOL *stop))block;

@end
