//
//  RocksDBRange.h
//  ObjectiveRocks
//
//  Created by Iska on 24/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a range of keys.
 */
@interface RocksDBKeyRange : NSObject

/* @breif Start key */
@property (nonatomic, strong, nullable) NSData * start;
/* @breif End key */
@property (nonatomic, strong, nullable) NSData * end;

/**
 Creates a new RocksDBKeyRange from the specified values.

 @return RocksDBKeyRange with start and end keys.
 */
- (instancetype)initWithStart:(nullable NSData *)start end:(nullable NSData *)end;

@end

/**
 A shorthand utility function for creating a new RocksDBKeyRange from the specified values.

 @return RocksDBKeyRange with start and end keys.
 */
NS_INLINE RocksDBKeyRange * RocksDBMakeKeyRange(NSData * _Nullable start, NSData * _Nullable end)
{
	return [[RocksDBKeyRange alloc] initWithStart:start end:end];
}

/**
 An "open" RocksDB range, i.e. the range that starts before the first and ends after the last keys.
 */
extern RocksDBKeyRange * const RocksDBOpenRange;

NS_ASSUME_NONNULL_END
