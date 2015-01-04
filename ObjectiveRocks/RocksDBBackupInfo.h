//
//  RocksDBBackupInfo.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBBackupInfo : NSObject

@property (nonatomic, assign) uint32_t backupId;
@property (nonatomic, assign) int64_t timestamp;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) uint32_t numberFiles;

@end
