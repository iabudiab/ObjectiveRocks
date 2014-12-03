//
//  RocksDBReadOptions.h
//  BCRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBReadOptions : NSObject <NSCopying> 

@property (nonatomic, assign) BOOL verifyChecksums;
@property (nonatomic, assign) BOOL fillCache;

@end
