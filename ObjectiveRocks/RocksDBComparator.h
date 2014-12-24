//
//  RocksDBComparator.h
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RocksDBComparatorType)
{
	RocksDBComparatorBytewiseAscending,
	RocksDBComparatorBytewiseDescending,
	RocksDBComparatorStringCompareAscending,
	RocksDBComparatorStringCompareDescending,
	RocksDBComparatorNumberAscending,
	RocksDBComparatorNumberDescending
};

@interface RocksDBComparator : NSObject

+ (instancetype)comaparatorWithType:(RocksDBComparatorType)type;

- (instancetype)initWithName:(NSString *)name andBlock:(int (^)(id key1, id key2))block;

@end
