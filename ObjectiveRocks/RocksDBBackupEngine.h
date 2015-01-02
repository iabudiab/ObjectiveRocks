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

- (BOOL)createBackupForDatabase:(RocksDB *)database error:(NSError * __autoreleasing *)error;
- (BOOL)restoreBackupToDestinationPath:(NSString *)destination error:(NSError * __autoreleasing *)error;

- (void)close;

@end
