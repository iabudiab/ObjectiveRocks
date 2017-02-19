//
//  RocksDBStatisticsTests.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBTests.h"

@interface RocksDBStatisticsTests : RocksDBTests

@end

@implementation RocksDBStatisticsTests

- (void)testStatistics
{
	RocksDBStatistics *statistics = [RocksDBStatistics new];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.statistics = statistics;
	}];

	[_rocks setData:@"abcd".data forKey:@"abcd".data error:nil];

	XCTAssertNotNil(statistics.description);
}

- (void)testStatistics_Ticker
{
	RocksDBStatistics *statistics = [RocksDBStatistics new];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.statistics = statistics;
	}];

	[_rocks setData:@"abcd".data forKey:@"abcd".data error:nil];

	XCTAssertEqual([statistics countForTicker:RocksDBTickerBytesRead], 0);
	XCTAssertGreaterThan([statistics countForTicker:RocksDBTickerBytesWritten], 0);

	[_rocks dataForKey:@"abcd".data error:nil];

	XCTAssertGreaterThan([statistics countForTicker:RocksDBTickerBytesRead], 0);
}

- (void)testStatistics_Histogram
{
	RocksDBStatistics *statistics = [RocksDBStatistics new];

	_rocks = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
		options.createIfMissing = YES;
		options.statistics = statistics;
	}];

	for (int i = 0; i < 10000; i++) {
		NSString *str = [NSString stringWithFormat:@"a%d", i];
		[_rocks setData:str.data forKey:str.data error:nil];
	}

	[_rocks dataForKey:@"a42".data error:nil];

	RocksDBStatisticsHistogram *dbGetHistogram = [statistics histogramDataForType:RocksDBHistogramDBGet];
	XCTAssertNotNil(dbGetHistogram);
	XCTAssertGreaterThan(dbGetHistogram.median, 0.0);
}

@end
