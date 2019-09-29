//
//  RocksDBCompactRangeOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 24/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Determines the behavior for compacting the bottommost level.
 */
typedef NS_ENUM(NSUInteger, RocksDBBottommostLevelCompaction)
{
	RocksDBBottommostLevelCompactionSkip,
	RocksDBBottommostLevelCompactionIfHaveCompactionFilter,
	RocksDBBottommostLevelCompactionForce,
	RocksDBBottommostLevelCompactionForceOptimized
};

/**
 The options used for range compactions.
 */
@interface RocksDBCompactRangeOptions : NSObject

/**
 If true, compacted files will be moved to the minimum level capable
 of holding the data or given level (specified non-negative targetLevel).
*/
@property (nonatomic, assign) BOOL changeLevel;

/**
 If change_level is true and target_level have non-negative value, compacted
 files will be moved to target_level.
*/
@property (nonatomic, assign) int targetLevel;

/**
 By default level based compaction will only compact the bottommost level if there is a compaction filter.
*/
@property (nonatomic, assign) RocksDBBottommostLevelCompaction bottommostLevelCompaction;

@end

NS_ASSUME_NONNULL_END
