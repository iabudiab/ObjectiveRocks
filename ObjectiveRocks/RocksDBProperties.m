//
//  RocksDBProperties.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBProperties.h"

NSString * const RocksDBPropertyNumFilesAtLevel = @"rocksdb.num-files-at-level%d";
NSString * const RocksDBPropertyLevelStats = @"rocksdb.levelstats";
NSString * const RocksDBPropertyCFStats = @"rocksdb.cfstats";
NSString * const RocksDBPropertyDBStats = @"rocksdb.dbstats";
NSString * const RocksDBPropertyStats = @"rocksdb.stats";
NSString * const RocksDBPropertySsTables = @"rocksdb.sstables";

NSString * const RocksDBIntPropertyNumImmutableMemTable = @"rocksdb.num-immutable-mem-table";
NSString * const RocksDBIntPropertyMemtableFlushPending = @"rocksdb.mem-table-flush-pending";
NSString * const RocksDBIntPropertyCompactionPending = @"rocksdb.compaction-pending";
NSString * const RocksDBIntPropertyBackgroundErrors = @"rocksdb.background-errors";
NSString * const RocksDBIntPropertyCurSizeActiveMemTable = @"rocksdb.cur-size-active-mem-table";
NSString * const RocksDBIntPropertyCurSizeAllMemTables = @"rocksdb.cur-size-all-mem-tables";
NSString * const RocksDBIntPropertyNumEntriesInMutableMemtable = @"rocksdb.num-entries-active-mem-table";
NSString * const RocksDBIntPropertyNumEntriesInImmutableMemtable = @"rocksdb.num-entries-imm-mem-tables";
NSString * const RocksDBIntPropertyEstimatedNumKeys = @"rocksdb.estimate-num-keys";
NSString * const RocksDBIntPropertyEstimatedUsageByTableReaders = @"rocksdb.estimate-table-readers-mem";
NSString * const RocksDBIntPropertyIsFileDeletionEnabled = @"rocksdb.is-file-deletions-enabled";
NSString * const RocksDBIntPropertyNumSnapshots = @"rocksdb.num-snapshots";
NSString * const RocksDBIntPropertyOldestSnapshotTime = @"rocksdb.oldest-snapshot-time";
