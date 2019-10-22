//
//  RocksDBCompactRangeOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 24/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "RocksDBCompactRangeOptions.h"

#import <rocksdb/options.h>

@interface RocksDBCompactRangeOptions ()
{
	rocksdb::CompactRangeOptions _options;
}
@end

@implementation RocksDBCompactRangeOptions

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::CompactRangeOptions();
	}
	return self;
}

#pragma mark - Options

- (BOOL)exclusiveManualCompaction
{
	return _options.exclusive_manual_compaction;
}

- (void)setExclusiveManualCompaction:(BOOL)exclusiveManualCompaction
{
	_options.exclusive_manual_compaction = exclusiveManualCompaction;
}

- (BOOL)changeLevel
{
	return _options.change_level;
}

- (void)setChangeLevel:(BOOL)changeLevel
{
	_options.change_level = changeLevel;
}

- (int)targetLevel
{
	return _options.target_level;
}

- (void)setTargetLevel:(int)targetLevel
{
	_options.target_level = targetLevel;
}

- (uint32_t)targetPathId
{
	return _options.target_path_id;
}

- (void)setTargetPathId:(uint32_t)targetPathId
{
	_options.target_path_id = targetPathId;
}

- (RocksDBBottommostLevelCompaction)bottommostLevelCompaction
{
	switch (_options.bottommost_level_compaction) {
		case rocksdb::BottommostLevelCompaction::kSkip:
			return RocksDBBottommostLevelCompactionSkip;
		case rocksdb::BottommostLevelCompaction::kIfHaveCompactionFilter:
			return RocksDBBottommostLevelCompactionIfHaveCompactionFilter;
		case rocksdb::BottommostLevelCompaction::kForce:
			return RocksDBBottommostLevelCompactionForce;
		case rocksdb::BottommostLevelCompaction::kForceOptimized:
			return RocksDBBottommostLevelCompactionForceOptimized;
	}
}

- (void)setBottommostLevelCompaction:(RocksDBBottommostLevelCompaction)bottommostLevelCompaction
{
	switch (bottommostLevelCompaction) {
		case RocksDBBottommostLevelCompactionSkip:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kSkip;
			break;
		case RocksDBBottommostLevelCompactionIfHaveCompactionFilter:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kIfHaveCompactionFilter;
			break;
		case RocksDBBottommostLevelCompactionForce:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kForce;
			break;
		case RocksDBBottommostLevelCompactionForceOptimized:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kForceOptimized;
			break;
	}
}

- (BOOL)allowWriteStall
{
	return _options.allow_write_stall;
}

- (void)setAllowWriteStall:(BOOL)allowWriteStall
{
	_options.allow_write_stall = allowWriteStall;
}

- (uint32_t)maxSubcompactions
{
	return _options.max_subcompactions;
}

- (void)setMaxSubcompactions:(uint32_t)maxSubcompactions
{
	_options.max_subcompactions = maxSubcompactions;
}

@end
