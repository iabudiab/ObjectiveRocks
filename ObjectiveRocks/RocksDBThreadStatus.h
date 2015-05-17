//
//  RocksDBThreadStatus.h
//  ObjectiveRocks
//
//  Created by Iska on 05/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The type of a thread. */
typedef NS_ENUM(int, RocksDBThreadType)
{
	/** @brief RocksDB background thread in high priority thread pool. */
	RocksDBThreadHighPiority = 0,

	/** @brief RocksDB background thread in low priority thread pool. */
	RocksDBThreadLowPiority,

	/** @brief User thread (Non-RocksDB background thread). */
	RocksDBThreadUser
};

/** 
 The type used to refer to a thread operation. A thread operation describes high-level action of a thread.
 */
typedef NS_ENUM(int, RocksDBOperationType)
{
	/** Unknown operation. */
	RocksDBOperationUnknown = 0,

	/** A compaction operation. */
	RocksDBOperationCompaction,

	/** A flush operation. */
	RocksDBOperationFlush
};

/** The type used to refer to a thread state. */
typedef NS_ENUM(int, RocksDBStateType)
{
	/** Unkown state. */
	RocksDBStateUnknown = 0,
};

/**
 Describes the current status of a thread.
 */
@interface RocksDBThreadStatus : NSObject

/** @brief An unique ID for the thread. */
@property (nonatomic, assign) uint64_t threadId;

/** @brief The type of the thread. */
@property (nonatomic, assign) RocksDBThreadType threadType;

/** @brief The name of the DB instance where the thread is currently involved with. 
 It would be set to empty string if the thread does not involve in any DB operation. */
@property (nonatomic, strong) NSString *databaseName;

/** @brief The name of the column family where the thread is currently It would be set 
 to empty string if the thread does not involve in any column family. */
@property (nonatomic, strong) NSString *columnFamilyname;

/** @brief The operation (high-level action) that the current thread is involved. */
@property (nonatomic, assign) RocksDBOperationType operationType;

/** @brief The state (lower-level action) that the current thread is involved. */
@property (nonatomic, assign) RocksDBStateType stateType;

@end
