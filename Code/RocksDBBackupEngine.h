//
//  RocksDBBackupEngine.h
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RocksDB.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The `RocksDBBackupEngine` provides backup and restore functionality for RocksDB. Backups are incremental and
 each backup receives an ID, which can be used to restore that specific backup. Backups can also be deleted to
 reduce the total size and reduce restoration times.
 */
@interface RocksDBBackupEngine : NSObject

/**
 Initializes a new Backup Enginge with the given path as a destination directory.

 @param path The destination path for the new Backup Engine.
 @return The newly-created Backup Engine with the given destination path.
 */
- (instancetype)initWithPath:(NSString *)path;

/**
 Creates a new backup of the given database instance.

 @param database The database instance for which a backup is to be created.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the backup succeeded, `NO` otherwise.
 */
- (BOOL)createBackupForDatabase:(RocksDB *)database error:(NSError * _Nullable *)error;

/**
 Restores the latest backup of this Backup Engine to the given destination path.

 @param destination The destination path where the last backup is to be restored to.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the restore succeeded, `NO` otherwise.
 */
- (BOOL)restoreBackupToDestinationPath:(NSString *)destination error:(NSError * _Nullable *)error;

/**
 Restores the backup with the given ID in this Backup Engine to the given destination path.

 @param backupId The backup ID to restore.
 @param destination The destination path where the last backup is to be restored to.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the restore succeeded, `NO` otherwise.
 */
- (BOOL)restoreBackupWithId:(uint32_t)backupId toDestinationPath:(NSString *)destination error:(NSError * _Nullable *)error;

/**
 Deleted all backups from this Backup Engine keeping the last N backups.
 
 @param countBackups The count of backaups to keep in this Backup Engine.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the purge succeeded, `NO` otherwise.
 */
- (BOOL)purgeOldBackupsKeepingLast:(uint32_t)countBackups error:(NSError * _Nullable *)error;

/**
 Deletes a specific backup from this Backup Engine.

 @param backupId The ID of the backaup to delete from this Backup Engine.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the delete succeeded, `NO` otherwise.
 */
- (BOOL)deleteBackupWithId:(uint32_t)backupId error:(NSError * _Nullable *)error;

/**
 Returns a list of backups in this Backup Engine together with information on timestamp of the backups
 and their sizes.

 @return An array containing `RocksDBBackupInfo` objects with informations about the backups.

 @see RocksDBBackupInfo
 */
- (NSArray *)backupInfo;

/**
 @brief Closes this Backup Engine instance.
 */
- (void)close;

@end

NS_ASSUME_NONNULL_END
