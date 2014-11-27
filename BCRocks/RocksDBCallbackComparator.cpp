//
//  RocksDBCallbackComparator.cpp
//  BCRocks
//
//  Created by Iska on 22/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBCallbackComparator.h"

class RocksDBCallbackComparatorImpl : public rocksdb::Comparator
{
private:
	void* instance;
	CompareCallback callback;

public:
	RocksDBCallbackComparatorImpl(void* instance, CompareCallback callback): instance(instance), callback(callback) {}

	virtual const char* Name() const
	{
		return "RocksDBCallbackComparator";
	}

	virtual int Compare(const rocksdb::Slice& a, const rocksdb::Slice& b) const
	{
		return callback(instance, a, b);
	}

	virtual void FindShortestSeparator(std::string* start,
									   const rocksdb::Slice& limit) const {}

	virtual void FindShortSuccessor(std::string* key) const {}
};

const rocksdb::Comparator* RocksDBCallbackComparator(void* instance, CompareCallback callback) {
	return new RocksDBCallbackComparatorImpl(instance, callback);
}
