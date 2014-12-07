//
//  RocksDBCallbackComparator.cpp
//  ObjectiveRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBCallbackComparator.h"

class RocksDBCallbackComparatorImpl : public rocksdb::Comparator
{
private:
	void* instance;
	const char* name;
	CompareCallback callback;

public:
	RocksDBCallbackComparatorImpl(void* instance,
								  const char* name,
								  CompareCallback callback): instance(instance), name(name), callback(callback) {}

	virtual const char* Name() const
	{
		return name;
	}

	virtual int Compare(const rocksdb::Slice& a, const rocksdb::Slice& b) const
	{
		return callback(instance, a, b);
	}

	virtual void FindShortestSeparator(std::string* start,
									   const rocksdb::Slice& limit) const {}

	virtual void FindShortSuccessor(std::string* key) const {}
};

const rocksdb::Comparator* RocksDBCallbackComparator(void* instance, const char* name, CompareCallback callback) {
	return new RocksDBCallbackComparatorImpl(instance, name, callback);
}
