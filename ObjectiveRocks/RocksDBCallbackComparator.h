//
//  RocksDBCallbackComparator.h
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#ifndef __ObjectiveRocks__RocksDBCallbackComparator__
#define __ObjectiveRocks__RocksDBCallbackComparator__

#import <rocksdb/comparator.h>
#import <rocksdb/slice.h>

typedef int (* CompareCallback)(void* instance, const rocksdb::Slice& a, const rocksdb::Slice& b);

extern const rocksdb::Comparator* RocksDBCallbackComparator(void* instance, CompareCallback callback);

#endif /* defined(__ObjectiveRocks__RocksDBCallbackComparator__) */
