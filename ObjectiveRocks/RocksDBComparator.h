//
//  RocksDBComparator.h
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBComparator : NSObject

+ (instancetype)comaparatorWithName:(NSString *)name andBlock:(int (^)(id key1, id key2))block;
- (instancetype)initWithName:(NSString *)name andBlock:(int (^)(id key1, id key2))block;

@end
