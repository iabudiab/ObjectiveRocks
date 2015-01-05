//
//  RocksDBThreadStatus.h
//  ObjectiveRocks
//
//  Created by Iska on 05/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RocksDBThreadType)
{
	RocksDBThreadHighPiority = 0x0,
	RocksDBThreadLowPiority = 0x1,
	RocksDBThreadUser = 0x2,
};

@interface RocksDBThreadStatus : NSObject

@property (nonatomic, assign) uint64_t threadId;
@property (nonatomic, assign) RocksDBThreadType threadType;
@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *columnFamilyname;
@property (nonatomic, strong) NSString *event;

@end
