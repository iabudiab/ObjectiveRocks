//
//  RocksDBDatabaseOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned char, RocksDBLogLevel)
{
	RocksDBLogLevelDebug = 0,
	RocksDBLogLevelInfo,
	RocksDBLogLevelWarn,
	RocksDBLogLevelError,
	RocksDBLogLevelFatal
};

@interface RocksDBDatabaseOptions : NSObject

@property (nonatomic, assign) BOOL createIfMissing;
@property (nonatomic, assign) BOOL createMissingColumnFamilies;
@property (nonatomic, assign) BOOL errorIfExists;
@property (nonatomic, assign) BOOL paranoidChecks;
@property (nonatomic, assign) RocksDBLogLevel infoLogLevel;
@property (nonatomic, assign) int  maxOpenFiles;
@property (nonatomic, assign) uint64_t  maxWriteAheadLogSize;
@property (nonatomic, assign) BOOL disableDataSync;
@property (nonatomic, assign) BOOL useFSync;
@property (nonatomic, assign) size_t maxLogFileSize;
@property (nonatomic, assign) size_t logFileTimeToRoll;
@property (nonatomic, assign) size_t keepLogFileNum;
@property (nonatomic, assign) uint64_t bytesPerSync;

@end
