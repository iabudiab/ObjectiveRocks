//
//  RocksDBCompactRangeOptions+Private.h
//  ObjectiveRocks
//
//  Created by Iska on 24/04/16.
//  Copyright © 2016 BrainCookie. All rights reserved.
//

#import "RocksDBCompactRangeOptions.h"

namespace rocksdb {
	class CompactRangeOptions;
}

/**
 This category is intended to hide all C++ types from the public interface in order to
 maintain a pure Objective-C API for Swift compatibility.
 */
@interface RocksDBCompactRangeOptions (Private)

/** @brief The underlying rocksdb::CompactRangeOptions associated with this instance. */
@property (nonatomic, assign) rocksdb::CompactRangeOptions options;

@end
