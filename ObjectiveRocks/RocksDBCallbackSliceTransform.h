//
//  RocksDBCallbackSliceTransform.h
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#ifndef __ObjectiveRocks__RocksDBCallbackSliceTransform__
#define __ObjectiveRocks__RocksDBCallbackSliceTransform__

#include <rocksdb/slice_transform.h>
#import <rocksdb/slice.h>

typedef rocksdb::Slice (* TransformCallback)(void* instance, const rocksdb::Slice& src);
typedef bool (* InDomainCallback)(void* instance, const rocksdb::Slice& src);
typedef bool (* InRangeCallback)(void* instance, const rocksdb::Slice& dst);

extern rocksdb::SliceTransform* RocksDBCallbackSliceTransform(void* instance,
															  const char* name,
															  TransformCallback transform,
															  InDomainCallback domain,
															  InRangeCallback range);

#endif /* defined(__ObjectiveRocks__RocksDBCallbackSliceTransform__) */
