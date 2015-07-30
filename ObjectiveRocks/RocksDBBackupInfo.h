//
//  RocksDBBackupInfo.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Holds information about a database backup.
 */
@interface RocksDBBackupInfo : NSObject

/**
 @brief The backup ID.
 */
@property (nonatomic, assign) uint32_t backupId;

/**
 @brief The timestamp when the backup was created.
 */
@property (nonatomic, assign) int64_t timestamp;

/**
 @brief The size of the backup in bytes.
 */
@property (nonatomic, assign) uint64_t size;

/**
 @brief The number of files in the backup.
 */
@property (nonatomic, assign) uint32_t numberFiles;

@end
