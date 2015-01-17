//
//  RocksDBThreadStatus.h
//  ObjectiveRocks
//
//  Created by Iska on 05/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, RocksDBThreadType)
{
	RocksDBThreadHighPiority = 0,
	RocksDBThreadLowPiority,
	RocksDBThreadUser
};

typedef NS_ENUM(int, RocksDBOperationType)
{
	RocksDBOperationUnknown = 0,
	RocksDBOperationCompaction,
	RocksDBOperationFlush
};

typedef NS_ENUM(int, RocksDBStateType)
{
	RocksDBStateUnknown = 0,
};

@interface RocksDBThreadStatus : NSObject

@property (nonatomic, assign) uint64_t threadId;
@property (nonatomic, assign) RocksDBThreadType threadType;
@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *columnFamilyname;
@property (nonatomic, assign) RocksDBOperationType operationType;
@property (nonatomic, assign) RocksDBStateType stateType;

@end
