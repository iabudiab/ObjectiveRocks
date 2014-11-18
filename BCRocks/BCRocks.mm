//
//  BCRocks.m
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "BCRocks.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

@implementation BCRocks

- (int)doStuff
{
	rocksdb::DB* db;
	rocksdb::Options options;

	options.create_if_missing = true;

	rocksdb::Status s = rocksdb::DB::Open(options, "/tmp/on-the-rocks", &db);
	assert(s.ok());

	s = db->Put(rocksdb::WriteOptions(), "key", "value");
	assert(s.ok());
	std::string value;

	s = db->Get(rocksdb::ReadOptions(), "key", &value);
	assert(s.ok());
	assert(value == "value");

	delete db;

	return 0;
}

@end
