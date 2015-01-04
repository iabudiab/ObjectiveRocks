//
//  RocksDBProperties.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RocksDBPropertyNumFilesAtLevel;
extern NSString * const RocksDBPropertyLevelStats;
extern NSString * const RocksDBPropertyCFStats;
extern NSString * const RocksDBPropertyDBStats;
extern NSString * const RocksDBPropertyStats;
extern NSString * const RocksDBPropertySsTables;

extern NSString * const RocksDBIntPropertyNumImmutableMemTable;
extern NSString * const RocksDBIntPropertyMemtableFlushPending;
extern NSString * const RocksDBIntPropertyCompactionPending;
extern NSString * const RocksDBIntPropertyBackgroundErrors;
extern NSString * const RocksDBIntPropertyCurSizeActiveMemTable;
extern NSString * const RocksDBIntPropertyCurSizeAllMemTables;
extern NSString * const RocksDBIntPropertyNumEntriesInMutableMemtable;
extern NSString * const RocksDBIntPropertyNumEntriesInImmutableMemtable;
extern NSString * const RocksDBIntPropertyEstimatedNumKeys;
extern NSString * const RocksDBIntPropertyEstimatedUsageByTableReaders;
extern NSString * const RocksDBIntPropertyIsFileDeletionEnabled;
extern NSString * const RocksDBIntPropertyNumSnapshots;
extern NSString * const RocksDBIntPropertyOldestSnapshotTime;
