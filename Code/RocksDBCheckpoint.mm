//
//  RocksDBCheckpoint.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBCheckpoint.h"
#import "RocksDB+Private.h"
#import "RocksDBError.h"

#import <rocksdb/utilities/checkpoint.h>

@interface RocksDBCheckpoint ()
{
	rocksdb::Checkpoint *_checkpoint;
}
@end

@implementation RocksDBCheckpoint

#pragma mark - Lifecycle

- (instancetype)initWithDatabase:(RocksDB *)database
{
	self = [super init];
	if (self) {
		rocksdb::Status status = rocksdb::Checkpoint::Create(database.db, &_checkpoint);
		if (!status.ok()) {
			NSLog(@"Error opening creating checkpoint: %@", [RocksDBError errorWithRocksStatus:status]);
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_checkpoint != nullptr)	{
			delete _checkpoint;
			_checkpoint = nullptr;
		}
	}
}

#pragma mark - Checkpoint Create

- (BOOL)createCheckpointAtPath:(NSString *)path error:(NSError **)error
{
	rocksdb::Status status = _checkpoint->CreateCheckpoint(path.UTF8String);

	if (!status.ok()) {
		NSError *temp = [RocksDBError errorWithRocksStatus:status];
		if (error && *error == nil) {
			*error = temp;
			return NO;
		}
	}
	return YES;
}

@end
