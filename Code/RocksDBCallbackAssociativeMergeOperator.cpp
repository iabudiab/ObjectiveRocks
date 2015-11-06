//
//  RocksDBCallbackAssociativeMergeOperator.cpp
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#include "RocksDBCallbackAssociativeMergeOperator.h"

class RocksDBCallbackAssociativeMergeOperatorImpl : public rocksdb::AssociativeMergeOperator
{
private:
	void* instance;
	const char* name;
	MergeCallback callback;
public:
	RocksDBCallbackAssociativeMergeOperatorImpl(void* instance,
												const char* name,
												MergeCallback callback): instance(instance), name(name), callback(callback) {}
	virtual const char* Name() const
	{
		return name;
	}

	virtual bool Merge(const rocksdb::Slice& key,
					   const rocksdb::Slice* existing_value,
					   const rocksdb::Slice& value,
					   std::string* new_value,
					   rocksdb::Logger* logger) const
	{
		return callback(instance, key, existing_value, value, new_value, logger);
	}
};

rocksdb::AssociativeMergeOperator* RocksDBCallbackAssociativeMergeOperator(void* instance, const char* name, MergeCallback callback)
{
	return new RocksDBCallbackAssociativeMergeOperatorImpl(instance, name, callback);
}
