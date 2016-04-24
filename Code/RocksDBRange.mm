//
//  RocksDBRange.m
//  ObjectiveRocks
//
//  Created by Iska on 24/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "RocksDBRange.h"

RocksDBKeyRange * const RocksDBOpenRange = RocksDBMakeKeyRange(nil, nil);

@implementation RocksDBKeyRange

- (instancetype)initWithStart:(id)start end:(id)end
{
	self = [super init];
	if (self) {
		self.start = start;
		self.end = end;
	}
	return self;
}

@end
