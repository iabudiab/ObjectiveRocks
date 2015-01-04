//
//  RocksDBBackupEngine.h
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RocksDB.h"

@interface RocksDBBackupEngine : NSObject

- (instancetype)initWithPath:(NSString *)path;

- (BOOL)createBackupForDatabase:(RocksDB *)database error:(NSError **)error;
- (BOOL)restoreBackupToDestinationPath:(NSString *)destination error:(NSError **)error;
- (BOOL)restoreBackupWithId:(uint32_t)backupId toDestinationPath:(NSString *)destination error:(NSError **)error;

- (BOOL)purgeOldBackupsKeepingLast:(uint32_t)countBackups error:(NSError **)error;
- (BOOL)deleteBackupWithId:(uint32_t)backupId error:(NSError **)error;

- (NSArray *)backupInfo;

- (void)close;

@end
