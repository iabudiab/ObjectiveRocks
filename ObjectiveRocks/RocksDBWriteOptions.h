//
//  RocksDBWriteOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBWriteOptions : NSObject <NSCopying> 

@property (nonatomic, assign) BOOL syncWrites;
@property (nonatomic, assign) BOOL disableWriteAheadLog;
@property (nonatomic, assign) uint64_t timeoutHint;
@property (nonatomic, assign) BOOL ignoreMissingColumnFamilies;

@end
