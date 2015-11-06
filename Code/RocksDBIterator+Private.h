//
//  RocksDBIterator+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBIterator.h"

namespace rocksdb {
	class Iterator;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBIterator (Private)

/**
 Initializes a new instance of `RocksDBIterator` with the given options and
 rocksdb::Iterator instance.

 @param iterator The rocks::Iterator instance.
 @param options The Encoding options.
 @return a newly-initialized instance of `RocksDBIterator`.

 @see RocksDBEncodingOptions
 */
- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator
				andEncodingOptions:(RocksDBEncodingOptions *)options;

@end
