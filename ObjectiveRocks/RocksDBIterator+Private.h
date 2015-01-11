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

@interface RocksDBIterator (Private)

- (instancetype)initWithDBIterator:(rocksdb::Iterator *)iterator
				andEncodingOptions:(RocksDBEncodingOptions *)options;

@end
