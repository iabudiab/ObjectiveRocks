//
//  RocksDBError.h
//  ObjectiveRocks
//
//  Created by Iska on 19/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace rocksdb {
	class Status;
}

extern NSString * const RocksDBErrorDomain;

@interface RocksDBError : NSObject

+ (NSError *)errorWithRocksStatus:(rocksdb::Status)status;
+ (NSError *)errorForMissingConversionBlock;

@end
