//
//  RocksDBThreadStatus.m
//  ObjectiveRocks
//
//  Created by Iska on 05/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBThreadStatus.h"

@interface RocksDBThreadStatus ()
@property (nonatomic, assign) uint64_t threadId;
@property (nonatomic, assign) RocksDBThreadType threadType;
@property (nonatomic, copy) NSString *databaseName;
@property (nonatomic, copy) NSString *columnFamilyname;
@property (nonatomic, assign) RocksDBOperationType operationType;
@property (nonatomic, assign) RocksDBStateType stateType;
@end

@implementation RocksDBThreadStatus
@synthesize threadId, threadType, databaseName, columnFamilyname, operationType, stateType;
@end
