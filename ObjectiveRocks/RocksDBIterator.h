//
//  RocksDBIterator.h
//  ObjectiveRocks
//
//  Created by Iska on 03/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBEncodingOptions.h"

@interface RocksDBIteratorKeyRange : NSObject

@property (nonatomic, strong) id start;
@property (nonatomic, strong) id end;

@end

NS_INLINE RocksDBIteratorKeyRange * RocksDBMakeKeyRange(id start, id end) {
	RocksDBIteratorKeyRange *range = [RocksDBIteratorKeyRange new];
	range.start = start;
	range.end = end;

	return range;
}

@interface RocksDBIterator : NSObject

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
- (void)enumerateKeysInRange:(RocksDBIteratorKeyRange *)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, BOOL *stop))block;

- (void)enumerateKeysAndValuesUsingBlock:(void (^)(id key, id value, BOOL *stop))block;
- (void)enumerateKeysAndValuesInReverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block;
- (void)enumerateKeysAndValuesInRange:(RocksDBIteratorKeyRange *)range reverse:(BOOL)reverse usingBlock:(void (^)(id key, id value, BOOL *stop))block;

- (void)enumerateKeysWithPrefix:(id)prefix usingBlock:(void (^)(id key, BOOL *stop))block;
- (void)enumerateKeysAndValuesWithPrefix:(id)prefix usingBlock:(void (^)(id key, id value, BOOL *stop))block;

@end
