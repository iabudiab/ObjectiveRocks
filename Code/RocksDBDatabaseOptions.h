//
//  RocksDBDatabaseOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RocksDBEnv;
@class RocksDBStatistics;

NS_ASSUME_NONNULL_BEGIN

/** @brief The DB log level. */
typedef NS_ENUM(unsigned char, RocksDBLogLevel)
{
	RocksDBLogLevelDebug = 0,
	RocksDBLogLevelInfo,
	RocksDBLogLevelWarn,
	RocksDBLogLevelError,
	RocksDBLogLevelFatal
};

/**
 Options to control the behavior of the DB.
 */
@interface RocksDBDatabaseOptions : NSObject

/** @brief If true, the database will be created if it is missing.
 The default is false. */
@property (nonatomic, assign) BOOL createIfMissing;

/** @brief If true, missing column families will be automatically created.
 The default is false. */
@property (nonatomic, assign) BOOL createMissingColumnFamilies;

/** @brief An error is raised if the database already exists.
 The default is false. */
@property (nonatomic, assign) BOOL errorIfExists;

/** @brief If true, RocksDB will aggressively check consistency of the data.
 Also, if any of the  writes to the database fails (Put, Delete, Merge,
 Write), the database will switch to read-only mode and fail all other
 Write operations.
 The default is true.
 */
@property (nonatomic, assign) BOOL paranoidChecks;

/** @brief The info log level. */
@property (nonatomic, assign) RocksDBLogLevel infoLogLevel;

/** @brief Number of open files that can be used by the DB.
 The default is 5000. */
@property (nonatomic, assign) int  maxOpenFiles;

/** @brief Once write-ahead logs exceed this size, column families whose
 memtables are  backed by the oldest live WAL file will be forced to flush.
 The default is 0. */
@property (nonatomic, assign) uint64_t  maxWriteAheadLogSize;

/** @brief If non-nil, metrics about database operations will be collected.
 Statistics objects should not be shared between DB instances.
 The default is nil.

 @see RocksDBStatistics
 */
@property (nonatomic, strong, nullable) RocksDBStatistics *statistics;

/** @brief If true, then the contents of manifest and data files are not
 synced to stable storage.
 The default is false. */
@property (nonatomic, assign) BOOL disableDataSync;

/** @brief If true, then every store to stable storage will issue a fsync.
 The default is false. */
@property (nonatomic, assign) BOOL useFSync;

/** @brief Specify the maximal size of the info log file. If maxLogFileSize == 0,
 all logs will be written to one log file.
 The default is 0. */
@property (nonatomic, assign) size_t maxLogFileSize;

/** @brief Time for the info log file to roll (in seconds).
 The default is 0 (disabled). */
@property (nonatomic, assign) size_t logFileTimeToRoll;

/** @brief Maximal info log files to be kept.
 The default is 1000. */
@property (nonatomic, assign) size_t keepLogFileNum;

/** @brief Allows OS to incrementally sync files to disk while they are being
 written, asynchronously, in the background.
 The default is 0. */
@property (nonatomic, assign) uint64_t bytesPerSync;

@end

NS_ASSUME_NONNULL_END
