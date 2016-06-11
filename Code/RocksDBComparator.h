//
//  RocksDBComparator.h
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An enum defining the built-in Comparators.
 */
typedef NS_ENUM(NSUInteger, RocksDBComparatorType)
{
	/** @brief Orders the keys lexicographically in ascending order. */
	RocksDBComparatorBytewiseAscending,

	/** @brief Orders the keys lexicographically in descending order. */
	RocksDBComparatorBytewiseDescending,

	/** @brief Orders NSString keys in ascending order via the compare selector. */
	RocksDBComparatorStringCompareAscending,

	/** @brief Orders NSString keys in descending order via the compare selector. */
	RocksDBComparatorStringCompareDescending,

	/** @brief Orders NSNumber keys in ascending order via the compare selector.*/
	RocksDBComparatorNumberAscending,

	/** @brief Orders NSNumber keys in descending order via the compare selector. */
	RocksDBComparatorNumberDescending
};

/**
 The keys are ordered within the key-value store according to a specified comparator function. The default ordering 
 function for keys orders the bytes lexicographically.

 This behavior can be changed by supplying a custom Comparator when opening a database using the `RocksDBComparator`.
 */
@interface RocksDBComparator : NSObject

/**
 Intializes a new Comparator instance for the given built-in type.

 @param type The comparator type.
 @return a newly-initialized instance of a keys comparator.
 */
+ (instancetype)comaparatorWithType:(RocksDBComparatorType)type;

/**
 Intializes a new Comparator instance with the given name and comparison block.

 @param name The name of the comparator.
 @param block The comparator block to apply on the keys in order to specify their order.
 @return a newly-initialized instance of a keys comparator.
 */
- (instancetype)initWithName:(NSString *)name andBlock:(int (^)(id key1, id key2))block;

@end

NS_ASSUME_NONNULL_END
