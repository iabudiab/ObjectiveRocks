//
//  RocksDBWriteBatchIterator+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 21/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatchIterator.h"

namespace rocksdb {
	class WBWIIterator;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBWriteBatchIterator (Private)

/**
 Initializes a new instance of `RocksDBWriteBatchIterator` with the given options and
 rocksdb::WBWIIterator instance.

 @param iterator The rocks::WBWIIterator instance.
 @return a newly-initialized instance of `RocksDBWriteBatchIterator`.
 */
- (instancetype)initWithWriteBatchIterator:(rocksdb::WBWIIterator *)iterator;

@end
