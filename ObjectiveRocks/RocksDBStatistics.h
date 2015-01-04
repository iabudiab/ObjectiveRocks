//
//  RocksDBStatistics.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBStatisticsHistogram.h"

typedef NS_ENUM(uint32_t, RocksDBStatisticsTicker)
{
	RocksDBStatisticsBlockCacheMiss = 0,
	RocksDBStatisticsBlockCacheHit,
	RocksDBStatisticsBlockCacheAdd,
	RocksDBStatisticsBlockCacheIndexMiss,
	RocksDBStatisticsBlockCacheIndexHit,
	RocksDBStatisticsBlockCacheFilterMiss,
	RocksDBStatisticsBlockCacheFilterHit,
	RocksDBStatisticsBlockCacheDataMiss,
	RocksDBStatisticsBlockCacheDataHit,
	RocksDBStatisticsBloomFilterUseful,
	RocksDBStatisticsMemtableHit,
	RocksDBStatisticsMemtableMiss,
	RocksDBStatisticsCompactionKeyDropNewerEntry,
	RocksDBStatisticsCompactionKeyDropObsolete,
	RocksDBStatisticsCompactionKeyDropUser,
	RocksDBStatisticsNumberKeysWritten,
	RocksDBStatisticsNumberKeysRead,
	RocksDBStatisticsNumberKeysUpdated,
	RocksDBStatisticsBytesWritten,
	RocksDBStatisticsBytesRead,
	RocksDBStatisticsNoFileCloses,
	RocksDBStatisticsNoFileOpens,
	RocksDBStatisticsNoFileErrors,
	RocksDBStatisticsStall_L0SlowdownMicros,
	RocksDBStatisticsStallMemtableCompactionMicros,
	RocksDBStatisticsStall_L0NumFilesMicros,
	RocksDBStatisticsEateLimitDelayMillis,
	RocksDBStatisticsNoIterators,
	RocksDBStatisticsNumberMultigetCalls,
	RocksDBStatisticsNumberMultigetKeysRead,
	RocksDBStatisticsNumberMultigetBytesRead,
	RocksDBStatisticsNumberFilteredDeletes,
	RocksDBStatisticsNumberMergeFailures,
	RocksDBStatisticsSequenceNumber,
	RocksDBStatisticsBloomFilterPrefixChecked,
	RocksDBStatisticsBloomFilterPrefixUseful,
	RocksDBStatisticsNumberOfReseeksInIteration,
	RocksDBStatisticsGetUpdatesSinceCalls,
	RocksDBStatisticsBlockCacheCompressedMiss,
	RocksDBStatisticsBlockCacheCompressedHit,
	RocksDBStatisticsWalFileSynced,
	RocksDBStatisticsWalFileBytes,
	RocksDBStatisticsWriteDoneBySelf,
	RocksDBStatisticsWriteDoneByOther,
	RocksDBStatisticsWriteTimedout,
	RocksDBStatisticsWriteWithWal,
	RocksDBStatisticsCompactReadBytes,
	RocksDBStatisticsCompactWriteBytes,
	RocksDBStatisticsFlushWriteBytes,
	RocksDBStatisticsNumberDirectLoadTableProperties,
	RocksDBStatisticsNumberSuperversionAcquires,
	RocksDBStatisticsNumberSuperversionReleases,
	RocksDBStatisticsNumberSuperversionCleanups,
	RocksDBStatisticsNumberBlockNotCompressed,
};

@interface RocksDBStatistics : NSObject

- (uint64_t)countForTicker:(RocksDBStatisticsTicker)ticker;
- (RocksDBStatisticsHistogram *)histogramForTicker:(RocksDBStatisticsTicker)ticker;
- (NSString *)description;

@end
