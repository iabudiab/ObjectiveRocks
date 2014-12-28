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

- (void)createBackupForDatabase:(RocksDB *)database;
- (void)restoreBackupToDestinationPath:(NSString *)destination;

- (void)close;

@end
