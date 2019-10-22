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
 If true the compaction is exclusive, if false other compactions may run concurrently at the same time.
 Default: true
*/
@property (nonatomic, assign) BOOL exclusiveManualCompaction;

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
 target_path_id for compaction output. Compaction outputs will be placed in options.dbPaths[target_path_id].
 Default: 0
*/
@property (nonatomic, assign) uint32_t targetPathId;

/**
 By default level based compaction will only compact the bottommost level if there is a compaction filter.
*/
@property (nonatomic, assign) RocksDBBottommostLevelCompaction bottommostLevelCompaction;

/**
 If true, compaction will execute immediately even if doing so would cause the DB to
 enter write stall mode. Otherwise, it'll sleep until load is low enough.
 Default: false
*/
@property (nonatomic, assign) BOOL allowWriteStall;

/**
 If > 0, it will replace the option in the DBOptions for this compaction
 Default: 0
*/
@property (nonatomic, assign) uint32_t maxSubcompactions;

@end

NS_ASSUME_NONNULL_END
