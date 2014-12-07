//
//  ObjectiveRocksError.m
//  ObjectiveRocks
//
//  Created by Iska on 19/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "ObjectiveRocksError.h"

NSString * const ObjectiveRocksErrorDomain = @"co.braincookie.objectiverocks.error";

@implementation ObjectiveRocksError

+ (NSError *)errorWithRocksStatus:(rocksdb::Status)status
{
	NSString *reason = [NSString stringWithUTF8String:status.ToString().c_str()];

	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey : @"Operation couldn't be completed",
							   NSLocalizedFailureReasonErrorKey : reason
							   };

	return [NSError errorWithDomain:ObjectiveRocksErrorDomain code:status.code() userInfo:userInfo];
}

@end
