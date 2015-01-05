//
//  RocksDBCuckooTableOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBCuckooTableOptions : NSObject

@property (nonatomic, assign) double hashTableRatio;
@property (nonatomic, assign) uint32_t maxSearchDepth;
@property (nonatomic, assign) uint32_t cuckooBlockSize;
@property (nonatomic, assign) BOOL identityAsFirstHash;
@property (nonatomic, assign) BOOL useModuleHash;

@end
