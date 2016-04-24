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

/* @breif Start key, inclusive */
@property (nonatomic, strong, nullable) id start;
/* @breif End key, exclusive */
@property (nonatomic, strong, nullable) id end;

/**
 Creates a new RocksDBKeyRange from the specified values.

 @return RocksDBKeyRange with start and end keys.
 */
- (instancetype)initWithStart:(__nullable id)start end:(__nullable id)end;

@end

/**
 A shorthand utility function for creating a new RocksDBKeyRange from the specified values.

 @return RocksDBKeyRange with start and end keys.
 */
NS_INLINE RocksDBKeyRange * RocksDBMakeKeyRange(__nullable id start, __nullable id end)
{
	return [[RocksDBKeyRange alloc] initWithStart:start end:end];
}

/**
 An "open" RocksDB range, i.e. the range that starts before the first and ends after the last keys.
 */
extern RocksDBKeyRange * const RocksDBOpenRange;

NS_ASSUME_NONNULL_END
