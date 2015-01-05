//
//  RocksDBEnv.h
//  ObjectiveRocks
//
//  Created by Iska on 05/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBEnv : NSObject

+ (instancetype)envWithLowPriorityThreadCount:(int)lowPrio andHighPriorityThreadCount:(int)highPrio;

- (void)setHighPriorityPoolThreadsCount:(int)numThreads;
- (void)setLowPriorityPoolThreadsCount:(int)numThreads;

#if ROCKSDB_USING_THREAD_STATUS
- (NSArray *)threadList;
#endif

@end
