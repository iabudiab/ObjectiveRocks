//
//  RocksDBOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
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

typedef NS_ENUM(char, RocksDBCompressionType)
{
	RocksDBCompressionNone = 0x0,
	RocksDBCompressionSnappy = 0x1,
	RocksDBCompressionZlib = 0x2,
	RocksDBCompressionBZip2 = 0x3,
	RocksDBCompressionLZ4 = 0x4,
	RocksDBCompressionLZ4HC = 0x5
};

@interface RocksDBOptions : NSObject

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

@interface RocksDBOptions (ColumnFamilyOptions)

@property (nonatomic) int (^comparator)(NSData *data1, NSData *data2);
@property (nonatomic, assign) size_t writeBufferSize;
@property (nonatomic, assign) int maxWriteBufferNumber;
@property (nonatomic, assign) RocksDBCompressionType compressionType;

@end
