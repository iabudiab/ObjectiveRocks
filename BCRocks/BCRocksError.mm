//
//  BCRocksError.m
//  BCRocks
//
//  Created by Iska on 19/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "BCRocksError.h"

NSString * const BCRocksErrorDomain = @"co.braincookie.bcrocks.error";

@implementation BCRocksError

+ (NSError *)errorWithRocksStatus:(rocksdb::Status)status
{
	NSString *reason = [NSString stringWithUTF8String:status.ToString().c_str()];

	NSDictionary *userInfo = @{
							   NSLocalizedDescriptionKey : @"Operation couldn't be completed",
							   NSLocalizedFailureReasonErrorKey : reason
							   };

	NSError *error = [[NSError alloc] initWithDomain:BCRocksErrorDomain
												code:status.code()
											userInfo:userInfo];
	return error;
}

@end
