//
//  RocksDBCheckpoint.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDB.h"

/**
 A checkpoint is an openable Snapshot of a database at a point in time. The `RocksDBCheckpoint` is used to
 create such Snapshots for a given DB.

 @see RocksDBSnapshot
 */
@interface RocksDBCheckpoint : NSObject

/**
 Initializes a new Checkpoint object instance for the given DB which is the nused to created the checkpoints.

 @return A newly-initialized Checkoint object instance.
 */
- (instancetype)initWithDatabase:(RocksDB *)db;

/**
 Creates a checkpoint, i.e. an openable snapshot, of the DB under the given path.

 @param path The path where the checkpint is to be created.
 @param error If an error occurs, upon return contains an `NSError` object that describes the problem.
 @return `YES` if the checkpoint was created, `NO` otherwise.
 */
- (BOOL)createCheckpointAtPath:(NSString *)path error:(NSError **)error;

@end
