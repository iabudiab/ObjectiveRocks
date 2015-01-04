//
//  RocksDBStatistics.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBStatisticsHistogram.h"

typedef NS_ENUM(uint32_t, RocksDBTickerType)
{
	RocksDBTickerBlockCacheMiss = 0,
	RocksDBTickerBlockCacheHit,
	RocksDBTickerBlockCacheAdd,
	RocksDBTickerBlockCacheIndexMiss,
	RocksDBTickerBlockCacheIndexHit,
	RocksDBTickerBlockCacheFilterMiss,
	RocksDBTickerBlockCacheFilterHit,
	RocksDBTickerBlockCacheDataMiss,
	RocksDBTickerBlockCacheDataHit,
	RocksDBTickerBloomFilterUseful,
	RocksDBTickerMemtableHit,
	RocksDBTickerMemtableMiss,
	RocksDBTickerCompactionKeyDropNewerEntry,
	RocksDBTickerCompactionKeyDropObsolete,
	RocksDBTickerCompactionKeyDropUser,
	RocksDBTickerNumberKeysWritten,
	RocksDBTickerNumberKeysRead,
	RocksDBTickerNumberKeysUpdated,
	RocksDBTickerBytesWritten,
	RocksDBTickerBytesRead,
	RocksDBTickerNoFileCloses,
	RocksDBTickerNoFileOpens,
	RocksDBTickerNoFileErrors,
	RocksDBTickerStall_L0SlowdownMicros,
	RocksDBTickerStallMemtableCompactionMicros,
	RocksDBTickerStall_L0NumFilesMicros,
	RocksDBTickerEateLimitDelayMillis,
	RocksDBTickerNoIterators,
	RocksDBTickerNumberMultigetCalls,
	RocksDBTickerNumberMultigetKeysRead,
	RocksDBTickerNumberMultigetBytesRead,
	RocksDBTickerNumberFilteredDeletes,
	RocksDBTickerNumberMergeFailures,
	RocksDBTickerSequenceNumber,
	RocksDBTickerBloomFilterPrefixChecked,
	RocksDBTickerBloomFilterPrefixUseful,
	RocksDBTickerNumberOfReseeksInIteration,
	RocksDBTickerGetUpdatesSinceCalls,
	RocksDBTickerBlockCacheCompressedMiss,
	RocksDBTickerBlockCacheCompressedHit,
	RocksDBTickerWalFileSynced,
	RocksDBTickerWalFileBytes,
	RocksDBTickerWriteDoneBySelf,
	RocksDBTickerWriteDoneByOther,
	RocksDBTickerWriteTimedout,
	RocksDBTickerWriteWithWal,
	RocksDBTickerCompactReadBytes,
	RocksDBTickerCompactWriteBytes,
	RocksDBTickerFlushWriteBytes,
	RocksDBTickerNumberDirectLoadTableProperties,
	RocksDBTickerNumberSuperversionAcquires,
	RocksDBTickerNumberSuperversionReleases,
	RocksDBTickerNumberSuperversionCleanups,
	RocksDBTickerNumberBlockNotCompressed,
};

typedef NS_ENUM(uint32_t, RocksDBHistogramType)
{
	RocksDBHistogramDBGet = 0,
	RocksDBHistogramDBWrite,
	RocksDBHistogramCompactionTime,
	RocksDBHistogramTableSyncMicros,
	RocksDBHistogramCompactionOutfileSyncMicros,
	RocksDBHistogramWalFileSyncMicros,
	RocksDBHistogramManifestFileSyncMicros,
	RocksDBHistogramTableOpenIOMicros,
	RocksDBHistogramDBMultiget,
	RocksDBHistogramReadBlockCompactionMicros,
	RocksDBHistogramReadBlockGetMicros,
	RocksDBHistogramWriteRawBlockMicros,
	RocksDBHistogramStall_L0SlowdownCount,
	RocksDBHistogramStallMemtableCompactionCount,
	RocksDBHistogramStall_L0NumFilesCount,
	RocksDBHistogramHardRateLimitDelayCount,
	RocksDBHistogramSoftRateLimitDelayCount,
	RocksDBHistogramNumFilesInSingleCompaction,
	RocksDBHistogramDBSeek,
	RocksDBHistogramWriteStall,
};

@interface RocksDBStatistics : NSObject

- (uint64_t)countForTicker:(RocksDBTickerType)ticker;
- (RocksDBStatisticsHistogram *)histogramDataForType:(RocksDBHistogramType)ticker;
- (NSString *)description;

@end
