//
//  RocksDBCallbackMergeOperator.h
//  ObjectiveRocks
//
//  Created by Iska on 15/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#ifndef __ObjectiveRocks__RocksDBCallbackMergeOperator__
#define __ObjectiveRocks__RocksDBCallbackMergeOperator__

#import <string>
#import <rocksdb/slice.h>
#import <rocksdb/env.h>
#import <rocksdb/merge_operator.h>

typedef bool (* PartialMergeCallback)(void* instance,
									  const rocksdb::Slice& key,
									  const rocksdb::Slice& left_operand,
									  const rocksdb::Slice& right_operand,
									  std::string* new_value,
									  rocksdb::Logger* logger);

typedef bool (* FullMergeCallback)(void* instance,
								   const rocksdb::Slice& key,
								   const rocksdb::Slice* existing_value,
								   const std::deque<std::string>& operand_list,
								   std::string* new_value,
								   rocksdb::Logger* logger);

extern rocksdb::MergeOperator* RocksDBCallbackMergeOperator(void* instance,
															const char* name,
															PartialMergeCallback partialMergeCallback,
															FullMergeCallback fullMergeCallback);

#endif /* defined(__ObjectiveRocks__RocksDBCallbackMergeOperator__) */
