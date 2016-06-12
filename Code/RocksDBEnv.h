//
//  RocksDBEnv.h
//  ObjectiveRocks
//
//  Created by Iska on 05/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 All file operations (and other operating system calls) issued by the RocksDB implementation are routed through an
 `RocksDBEnv` object. Currently `RocksDBEnv` only exposes the high & low priority thread pool parameters.
 */
@interface RocksDBEnv : NSObject

/**
 Initializes a new Env instane with the given high & low priority background threads.

 @param lowPrio The count of thread for the high priority queue.
 @param highPrio The count of thread for the low priority queue.
 @return A newly-initialized instance with the given number of threads.
 */
+ (instancetype)envWithLowPriorityThreadCount:(int)lowPrio andHighPriorityThreadCount:(int)highPrio;

/**  @brief Sets the count of thread for the high priority queue. */
- (void)setHighPriorityPoolThreadsCount:(int)numThreads;

/**  @brief Sets the count of thread for the low priority queue. */
- (void)setLowPriorityPoolThreadsCount:(int)numThreads;

#if ROCKSDB_USING_THREAD_STATUS
/**
 Returns an array with the status of all threads that belong to the current Env.

 @see RocksDBThreadStatus

 @warning This method is not available in RocksDB Lite.
 */
- (NSArray *)threadList;
#endif

@end

NS_ASSUME_NONNULL_END
