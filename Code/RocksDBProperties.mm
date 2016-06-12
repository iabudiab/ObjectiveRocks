//
//  RocksDBProperties.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBProperties.h"

#import <rocksdb/db.h>

NSString * ResolveProperty(RocksDBProperty property) {
	switch (property) {
		case RocksDBPropertyNumFilesAtLevel:
			return @(rocksdb::DB::Properties::kNumFilesAtLevelPrefix.c_str());
		case RocksDBPropertyStats:
			return @(rocksdb::DB::Properties::kStats.c_str());
		case RocksDBPropertySsTables:
			return @(rocksdb::DB::Properties::kSSTables.c_str());
		case RocksDBPropertyCFStats:
			return @(rocksdb::DB::Properties::kCFStats.c_str());
		case RocksDBPropertyDBStats:
			return @(rocksdb::DB::Properties::kDBStats.c_str());
		default:
			return @"";
	}
}

NSString * ResolveIntProperty(RocksDBIntProperty property) {
	switch (property) {
		case RocksDBIntPropertyNumImmutableMemTable:
			return @(rocksdb::DB::Properties::kNumImmutableMemTable.c_str());
		case RocksDBIntPropertyMemtableFlushPending:
			return @(rocksdb::DB::Properties::kMemTableFlushPending.c_str());
		case RocksDBIntPropertyCompactionPending:
			return @(rocksdb::DB::Properties::kCompactionPending.c_str());
		case RocksDBIntPropertyBackgroundErrors:
			return @(rocksdb::DB::Properties::kBackgroundErrors.c_str());
		case RocksDBIntPropertyCurSizeActiveMemTable:
			return @(rocksdb::DB::Properties::kCurSizeActiveMemTable.c_str());
		case RocksDBIntPropertyCurSizeAllMemTables:
			return @(rocksdb::DB::Properties::kCurSizeAllMemTables.c_str());
		case RocksDBIntPropertyNumEntriesActiveMemtable:
			return @(rocksdb::DB::Properties::kNumEntriesActiveMemTable.c_str());
		case RocksDBIntPropertyNumEntriesImmutableMemtables:
			return @(rocksdb::DB::Properties::kNumEntriesImmMemTables.c_str());
		case RocksDBIntPropertyNumDeletesActiveMemtable:
			return @(rocksdb::DB::Properties::kNumDeletesActiveMemTable.c_str());
		case RocksDBIntPropertyNumDeletesImmutableMemtables:
			return @(rocksdb::DB::Properties::kNumDeletesImmMemTables.c_str());
		case RocksDBIntPropertyEstimatedNumKeys:
			return @(rocksdb::DB::Properties::kEstimateNumKeys.c_str());
		case RocksDBIntPropertyEstimatedUsageByTableReaders:
			return @(rocksdb::DB::Properties::kEstimateTableReadersMem.c_str());
		case RocksDBIntPropertyIsFileDeletionEnabled:
			return @(rocksdb::DB::Properties::kIsFileDeletionsEnabled.c_str());
		case RocksDBIntPropertyNumSnapshots:
			return @(rocksdb::DB::Properties::kNumSnapshots.c_str());
		case RocksDBIntPropertyOldestSnapshotTime:
			return @(rocksdb::DB::Properties::kOldestSnapshotTime.c_str());
		case RocksDBIntPropertyNumLiveVersions:
			return @(rocksdb::DB::Properties::kNumLiveVersions.c_str());
		default:
			return @"";
	}
}
