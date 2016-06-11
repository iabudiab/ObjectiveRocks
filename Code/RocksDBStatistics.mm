//
//  RocksDBStatistics.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBStatistics.h"

#import <rocksdb/statistics.h>

#pragma mark - Informal Protocols

@interface RocksDBStatistics ()
{
	std::shared_ptr<rocksdb::Statistics> _statistics;
}
@property (nonatomic, assign) std::shared_ptr<rocksdb::Statistics> statistics;
@end

@interface RocksDBStatisticsHistogram ()
@property (nonatomic, copy) NSString *ticker;
@property (nonatomic, assign) double median;
@property (nonatomic, assign) double percentile95;
@property (nonatomic, assign) double percentile99;
@property (nonatomic, assign) double average;
@property (nonatomic, assign) double standardDeviation;
@end

#pragma mark - Impl

@implementation RocksDBStatistics
@synthesize statistics = _statistics;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_statistics = rocksdb::CreateDBStatistics();
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_statistics != nullptr) {
			_statistics.reset();
		}
	}
}

#pragma mark - Accessor

- (uint64_t)countForTicker:(RocksDBTickerType)ticker
{
	return _statistics->getTickerCount(ticker);
}

- (RocksDBStatisticsHistogram *)histogramDataForType:(RocksDBHistogramType)ticker
{
	rocksdb::HistogramData *data = new rocksdb::HistogramData;
	_statistics->histogramData(ticker, data);

	RocksDBStatisticsHistogram *histogram = [RocksDBStatisticsHistogram new];

	std::string tickerName = rocksdb::HistogramsNameMap[ticker].second;

	histogram.ticker = [NSString stringWithCString:tickerName.c_str() encoding:NSUTF8StringEncoding];
	histogram.median = data->median;
	histogram.percentile95 = data->percentile95;
	histogram.percentile95 = data->percentile99;
	histogram.average = data->average;
	histogram.standardDeviation = data->standard_deviation;

	delete data;

	return histogram;
}

#pragma mark - Description

- (NSString *)description
{
	return [NSString stringWithCString:_statistics->ToString().c_str() encoding:NSUTF8StringEncoding];
}

@end
