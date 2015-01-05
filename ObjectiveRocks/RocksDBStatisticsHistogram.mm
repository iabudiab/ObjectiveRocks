//
//  RocksDBStatisticsHistogram.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBStatisticsHistogram.h"

@implementation RocksDBStatisticsHistogram

- (NSString *)description
{
	return [NSString stringWithFormat:@"<Histogram Type: %@, Median: %f, Percentile 95: %f, Pernectile 99: %f, Average: %f, Standard Deviation: %f>",
			self.ticker,
			self.median,
			self.percentile95,
			self.percentile99,
			self.average,
			self.standardDeviation];
}

@end
