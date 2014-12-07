//
//  RocksDBComparator.h
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <rocksdb/comparator.h>

@interface RocksDBComparator : NSObject

@property (readonly) const rocksdb::Comparator *comparator;

- (instancetype)initWithBlock:(int (^)(NSData *data1, NSData *data2))block;

@end
