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

- (RocksDBBottommostLevelCompaction)bottommostLevelCompaction
{
	switch (_options.bottommost_level_compaction) {
		case rocksdb::BottommostLevelCompaction::kSkip:
			return RocksDBBottommostLevelCompactionSkip;
		case rocksdb::BottommostLevelCompaction::kIfHaveCompactionFilter:
			return RocksDBBottommostLevelCompactionIfHaveCompactionFilter;
		case rocksdb::BottommostLevelCompaction::kForce:
			return RocksDBBottommostLevelCompactionForce;
	}
}

- (void)setBottommostLevelCompaction:(RocksDBBottommostLevelCompaction)bottommostLevelCompaction
{
	switch (bottommostLevelCompaction) {
		case RocksDBBottommostLevelCompactionSkip:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kSkip;
		case RocksDBBottommostLevelCompactionIfHaveCompactionFilter:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kIfHaveCompactionFilter;
		case RocksDBBottommostLevelCompactionForce:
			_options.bottommost_level_compaction = rocksdb::BottommostLevelCompaction::kForce;
	}
}

@end
