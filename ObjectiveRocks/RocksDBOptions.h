//
//  RocksDBOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RocksDBDatabaseOptions.h"
#import "RocksDBEncodingOptions.h"
#import "RocksDBColumnFamilyOptions.h"
#import "RocksDBComparator.h"
#import "RocksDBMergeOperator.h"
#import "RocksDBPrefixExtractor.h"
#import "RocksDBTypes.h"

@interface RocksDBOptions : NSObject

- (instancetype)initWithDatabaseOptions:(RocksDBDatabaseOptions *)dbOptions
				 andColumnFamilyOptions:(RocksDBColumnFamilyOptions *)columnFamilyOptions;

@end

@interface RocksDBOptions (Encoding)

@property (nonatomic, copy) NSData * (^ keyEncoder)(id key);
@property (nonatomic, copy) id (^ keyDecoder)(NSData *data);
@property (nonatomic, copy) NSData * (^ valueEncoder)(id key, id value);
@property (nonatomic, copy) id (^ valueDecoder)(id key, NSData *data);

@property (nonatomic, assign) RocksDBType keyType;
@property (nonatomic, assign) RocksDBType valueType;

@end

@interface RocksDBOptions (DBOptions)

@property (nonatomic, assign) BOOL createIfMissing;
@property (nonatomic, assign) BOOL createMissingColumnFamilies;
@property (nonatomic, assign) BOOL errorIfExists;
@property (nonatomic, assign) BOOL paranoidChecks;
@property (nonatomic, assign) RocksDBLogLevel infoLogLevel;
@property (nonatomic, assign) int  maxOpenFiles;
@property (nonatomic, assign) uint64_t  maxWriteAheadLogSize;
@property (nonatomic, strong) RocksDBStatistics *statistics;
@property (nonatomic, assign) BOOL disableDataSync;
@property (nonatomic, assign) BOOL useFSync;
@property (nonatomic, assign) size_t maxLogFileSize;
@property (nonatomic, assign) size_t logFileTimeToRoll;
@property (nonatomic, assign) size_t keepLogFileNum;
@property (nonatomic, assign) uint64_t bytesPerSync;

@end

@interface RocksDBOptions (ColumnFamilyOptions)

@property (nonatomic, strong) RocksDBComparator *comparator;
@property (nonatomic, strong) RocksDBMergeOperator *mergeOperator;
@property (nonatomic, strong) RocksDBPrefixExtractor *prefixExtractor;
@property (nonatomic, assign) size_t writeBufferSize;
@property (nonatomic, assign) int maxWriteBufferNumber;
@property (nonatomic, assign) int minWriteBufferNumberToMerge;
@property (nonatomic, assign) RocksDBCompressionType compressionType;
@property (nonatomic, assign) int numLevels;
@property (nonatomic, assign) int level0FileNumCompactionTrigger;
@property (nonatomic, assign) int level0SlowdownWritesTrigger;
@property (nonatomic, assign) int level0StopWritesTrigger;
@property (nonatomic, assign) int maxMemCompactionLevel;
@property (nonatomic, assign) uint64_t targetFileSizeBase;
@property (nonatomic, assign) int targetFileSizeMultiplier;
@property (nonatomic, assign) uint64_t maxBytesForLevelBase;
@property (nonatomic, assign) int maxBytesForLevelMultiplier;
@property (nonatomic, assign) int expandedCompactionFactor;
@property (nonatomic, assign) int sourceCompactionFactor;
@property (nonatomic, assign) int maxGrandparentOverlapFactor;
@property (nonatomic, assign) double softRateLimit;
@property (nonatomic, assign) double hardRateLimit;
@property (nonatomic, assign) unsigned int rateLimitDelayMaxMilliseconds;
@property (nonatomic, assign) size_t arenaBlockSize;
@property (nonatomic, assign) BOOL disableAutoCompactions;
@property (nonatomic, assign) BOOL purgeRedundantKvsWhileFlush;
@property (nonatomic, assign) BOOL verifyChecksumsInCompaction;
@property (nonatomic, assign) BOOL filterDeletes;
@property (nonatomic, assign) uint64_t maxSequentialSkipInIterations;
@property (nonatomic, strong) RocksDBTableFactory *tableFacotry;
@property (nonatomic, assign) uint32_t memtablePrefixBloomBits;
@property (nonatomic, assign) uint32_t memtablePrefixBloomProbes;
@property (nonatomic, assign) size_t memtablePrefixBloomHugePageTlbSize;
@property (nonatomic, assign) uint32_t bloomLocality;
@property (nonatomic, assign) size_t maxSuccessiveMerges;
@property (nonatomic, assign) uint32_t minPartialMergeOperands;

@end

