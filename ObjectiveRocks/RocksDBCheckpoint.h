//
//  RocksDBCheckpoint.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDB.h"

@interface RocksDBCheckpoint : NSObject

- (instancetype)initWithDatabase:(RocksDB *)db;

- (BOOL)createCheckpointAtPath:(NSString *)path error:(NSError **)error;

@end
