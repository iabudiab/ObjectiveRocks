//
//  RocksDBIndexedWriteBatch.h
//  ObjectiveRocks
//
//  Created by Iska on 20/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatch.h"
#import "RocksDBWriteBatchIterator.h"

@interface RocksDBIndexedWriteBatch : RocksDBWriteBatch

/**
 Creates and returns an iterator over this indexed write batch.

 @discussion Keys will be iterated in the order given by the write batch's
 comparator. For multiple updates on the same key, each update will be 
 returned as a separate entry, in the order of update time.

 @return An iterator over this indexed write batch.

 @see RocksDBWriteBatchIterator
 */
- (RocksDBWriteBatchIterator *)iterator;

@end
