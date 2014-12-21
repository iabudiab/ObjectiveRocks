//
//  RocksDBCallbackMergeOperator.cpp
//  ObjectiveRocks
//
//  Created by Iska on 15/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#include "RocksDBCallbackMergeOperator.h"

class RocksDBCallbackMergeOperatorImpl : public rocksdb::MergeOperator
{
private:
	void* instance;
	const char* name;
	PartialMergeCallback partialMergeCallback;
	FullMergeCallback fullMergeCallback;
public:
	RocksDBCallbackMergeOperatorImpl(void* instance,
									 const char* name,
									 PartialMergeCallback partialMergeCallback,
									 FullMergeCallback fullMergeCallback):
	instance(instance), name(name), partialMergeCallback(partialMergeCallback), fullMergeCallback(fullMergeCallback) {}

	const char* Name() const
	{
		return name;
	}

	virtual bool FullMerge(const rocksdb::Slice& key,
				   const rocksdb::Slice* existing_value,
				   const std::deque<std::string>& operand_list,
				   std::string* new_value,
				   rocksdb::Logger* logger) const
	{
		return fullMergeCallback(instance, key, existing_value, operand_list, new_value, logger);
	};

	virtual bool PartialMerge(const rocksdb::Slice& key,
					  const rocksdb::Slice& left_operand,
					  const rocksdb::Slice& right_operand,
					  std::string* new_value,
					  rocksdb::Logger* logger) const
	{
		return partialMergeCallback(instance, key, left_operand, right_operand, new_value, logger);
	}
};

rocksdb::MergeOperator* RocksDBCallbackMergeOperator(void* instance,
													 const char* name,
													 PartialMergeCallback partialMergeCallback,
													 FullMergeCallback fullMergeCallback)
{
	return new RocksDBCallbackMergeOperatorImpl(instance, name, partialMergeCallback, fullMergeCallback);
}

