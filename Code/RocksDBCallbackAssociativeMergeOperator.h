//
//  RocksDBCallbackAssociativeMergeOperator.h
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#ifndef __ObjectiveRocks__RocksDBCallbackAssociativeMergeOperator__
#define __ObjectiveRocks__RocksDBCallbackAssociativeMergeOperator__

#import <string>
#import <rocksdb/slice.h>
#import <rocksdb/env.h>
#import <rocksdb/merge_operator.h>

typedef bool (* MergeCallback)(void* instacne,
							   const rocksdb::Slice& key,
							   const rocksdb::Slice* existing_value,
							   const rocksdb::Slice& value,
							   std::string* new_value,
							   rocksdb::Logger* logger);

extern rocksdb::AssociativeMergeOperator* RocksDBCallbackAssociativeMergeOperator(void* instance, const char* name, MergeCallback callback);

#endif /* defined(__ObjectiveRocks__RocksDBCallbackAssociativeMergeOperator__) */
