//
//  BCRocksError.h
//  BCRocks
//
//  Created by Iska on 19/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <rocksdb/db.h>

extern NSString * const BCRocksErrorDomain;

@interface BCRocksError : NSObject

+ (NSError *)errorWithRocksStatus:(rocksdb::Status)status;

@end
