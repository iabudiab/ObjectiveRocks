//
//  RocksDBError.m
//  ObjectiveRocks
//
//  Created by Iska on 19/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBError.h"

#import <rocksdb/status.h>

NSString * const RocksDBErrorDomain = @"co.braincookie.objectiverocks.error";
NSString * const RocksDBSubcodeKey = @"rocksdb.subcode";

@implementation RocksDBError

+ (NSError *)errorWithRocksStatus:(rocksdb::Status)status
{
	NSString *reason = [NSString stringWithUTF8String:status.ToString().c_str()];

	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey : @"Operation couldn't be completed",
							   NSLocalizedFailureReasonErrorKey : reason,
                               RocksDBSubcodeKey: @(status.subcode())
							   };

	return [NSError errorWithDomain:RocksDBErrorDomain code:status.code() userInfo:userInfo];
}

+ (NSError *)errorForMissingConversionBlock
{
	NSString *reason = @"Missing key/value encoder blocks";
	NSString *recovery = @"Provide encoder blocks for key/value objects in the RocksDB Options when initing the database";

	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey : @"Operation couldn't be completed",
							   NSLocalizedFailureReasonErrorKey : reason,
							   NSLocalizedRecoverySuggestionErrorKey: recovery
							   };

	return [NSError errorWithDomain:RocksDBErrorDomain code:3000 userInfo:userInfo];
}

@end
