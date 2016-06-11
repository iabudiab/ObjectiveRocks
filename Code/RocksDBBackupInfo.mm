//
//  RocksDBBackupInfo.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBBackupInfo.h"

@interface RocksDBBackupInfo ()
@property (nonatomic, assign) uint32_t backupId;
@property (nonatomic, assign) int64_t timestamp;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) uint32_t numberFiles;
@end

@implementation RocksDBBackupInfo
@synthesize backupId, timestamp, size, numberFiles;
@end
