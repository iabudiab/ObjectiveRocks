//
//  BCRocks.m
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "BCRocks.h"
#import "BCRocksError.h"

#include <rocksdb/db.h>
#include <rocksdb/slice.h>
#include <rocksdb/options.h>

@interface BCRocks ()
{
	rocksdb::DB *_db;
}
@end

@implementation BCRocks

#pragma mark - Lifecycle

- (instancetype)initWithPath:(NSString *)path
{
	self = [super init];
	if (self) {
		rocksdb::Options options;
		rocksdb::Status status = rocksdb::DB::Open(options, path.UTF8String, &_db);
		if (!status.ok()) {
			NSLog(@"Error creating database: %@", [BCRocksError errorWithRocksStatus:status]);
			[self close];
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[self close];
}

- (void)close
{
	@synchronized(self) {
		if (_db != NULL) {
			delete _db;
			_db = NULL;
		}
	}
}

@end
