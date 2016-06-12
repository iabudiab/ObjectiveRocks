//
//  RocksDBProperties.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RocksDBProperty)
{
	RocksDBPropertyNumFilesAtLevel,
	RocksDBPropertyStats,
	RocksDBPropertySsTables,
	RocksDBPropertyCFStats,
	RocksDBPropertyDBStats,
};

typedef NS_ENUM(NSUInteger, RocksDBIntProperty)
{
	RocksDBIntPropertyNumImmutableMemTable,
	RocksDBIntPropertyMemtableFlushPending,
	RocksDBIntPropertyCompactionPending,
	RocksDBIntPropertyBackgroundErrors,
	RocksDBIntPropertyCurSizeActiveMemTable,
	RocksDBIntPropertyCurSizeAllMemTables,
	RocksDBIntPropertyNumDeletesActiveMemtable,
	RocksDBIntPropertyNumDeletesImmutableMemtables,
	RocksDBIntPropertyNumEntriesActiveMemtable,
	RocksDBIntPropertyNumEntriesImmutableMemtables,
	RocksDBIntPropertyEstimatedNumKeys,
	RocksDBIntPropertyEstimatedUsageByTableReaders,
	RocksDBIntPropertyIsFileDeletionEnabled,
	RocksDBIntPropertyNumSnapshots,
	RocksDBIntPropertyOldestSnapshotTime,
	RocksDBIntPropertyNumLiveVersions
};

extern NSString * ResolveProperty(RocksDBProperty property);
extern NSString * ResolveIntProperty(RocksDBIntProperty property);
