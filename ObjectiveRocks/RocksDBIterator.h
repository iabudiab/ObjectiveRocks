//
//  RocksDBIterator.h
//  ObjectiveRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBOptions.h"

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

- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator andOptions:(RocksDBOptions *)options;
- (void)close;

- (BOOL)isValid;
- (void)seekToFirst;
- (void)seekToLast;
- (void)seekToKey:(NSData *)aKey;
- (void)next;
- (void)previous;
- (id)key;
- (id)value;

- (void)enumerateKeysUsingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysInReverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysInRange:(RocksDBIteratorKeyRange)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;

@end
