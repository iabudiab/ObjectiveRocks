//
//  RocksDBStatisticsHistogram.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @brief Holds histogram data. */
@interface RocksDBStatisticsHistogram : NSObject

/** @brief The name of this histogram type. */
@property (nonatomic, copy) NSString *ticker;

/** @brief The median value. */
@property (nonatomic, assign) double median;

/** @brief The percentile95 value. */
@property (nonatomic, assign) double percentile95;

/** @brief The percentile99 value. */
@property (nonatomic, assign) double percentile99;

/** @brief The average value. */
@property (nonatomic, assign) double average;

/** @brief The standard deviation value. */
@property (nonatomic, assign) double standardDeviation;

@end
