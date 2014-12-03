//
//  RocksDBIterator.h
//  BCRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct RocksDBIteratorRange
{
	NSData *start;
	NSData *end;
} RocksDBIteratorRange;

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
- (void)enumerateKeysWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(id key, BOOL *stop))block;

@end
