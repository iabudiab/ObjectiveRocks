//
//  RocksDBCallbackSliceTransform.cpp
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#include "RocksDBCallbackSliceTransform.h"

class RocksDBCallbackSliceTransformImpl : public rocksdb::SliceTransform
{
private:
	void* instance;
	const char* name;
	TransformCallback transformCallback;
	InDomainCallback inDomainCallback;
	InRangeCallback inRangeCallback;
	
public:
	RocksDBCallbackSliceTransformImpl(void* instance, const char* name,
									  TransformCallback transform,
									  InDomainCallback domain,
									  InRangeCallback range):
	instance(instance), name(name), transformCallback(transform), inDomainCallback(domain), inRangeCallback(range) {}

	virtual const char* Name() const
	{
		return name;
	}

	virtual rocksdb::Slice Transform(const rocksdb::Slice& src) const
	{
		return transformCallback(instance, src);
	}

	virtual bool InDomain(const rocksdb::Slice& src) const
	{
		return inDomainCallback(instance, src);
	}

	virtual bool InRange(const rocksdb::Slice& dst) const
	{
		return inRangeCallback(instance, dst);
	}

};

rocksdb::SliceTransform* RocksDBCallbackSliceTransform(void* instance,
													   const char* name,
													   TransformCallback transform,
													   InDomainCallback domain,
													   InRangeCallback range)
{
	return new RocksDBCallbackSliceTransformImpl(instance, name, transform, domain, range);
}
