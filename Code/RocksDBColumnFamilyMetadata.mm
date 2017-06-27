//
//  RocksDBColumnFamilyMetaData.m
//  ObjectiveRocks
//
//  Created by Iska on 09/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyMetadata.h"
#import "RocksDBColumnFamilyMetaData+Private.h"

#import <rocksdb/metadata.h>

@implementation RocksDBColumnFamilyMetaData

- (instancetype)initWithMetaData:(rocksdb::ColumnFamilyMetaData)metadata
{
	self = [super init];
	if (self) {
		self->_size = metadata.size;
		self->_fileCount = metadata.file_count;
		self->_name = [NSString stringWithCString:metadata.name.c_str() encoding:NSUTF8StringEncoding];
		NSMutableArray *levels = [NSMutableArray array];
		for (auto it = std::begin(metadata.levels); it != std::end(metadata.levels); ++it) {
			RocksDBLevelFileMetaData *levelMetaData = [[RocksDBLevelFileMetaData alloc] initWithLevelMetaData:*it];
			[levels addObject:levelMetaData];
		}
		self->_levels = levels;
	}
	return self;
}

@end

@implementation RocksDBLevelFileMetaData

- (instancetype)initWithLevelMetaData:(rocksdb::LevelMetaData)metadata
{
	self = [super init];
	if (self) {
		self->_level = metadata.level;
		self->_size = metadata.size;

		NSMutableArray *sstFiles = [NSMutableArray array];
		for (auto it = std::begin(metadata.files); it != std::end(metadata.files); ++it) {
			RocksDBSstFileMetaData *sstFileMetaData = [[RocksDBSstFileMetaData alloc] initWithSstFileMetaData:*it];
			[sstFiles addObject:sstFileMetaData];
		}
		self->_files = sstFiles;
	}
	return self;
}

@end

@implementation RocksDBSstFileMetaData

- (instancetype)initWithSstFileMetaData:(rocksdb::SstFileMetaData)metadata
{
	self = [super init];
	if (self) {
		self->_size = metadata.size;
		self->_name = [NSString stringWithCString:metadata.name.c_str() encoding:NSUTF8StringEncoding];
		self->_dbPath = [NSString stringWithCString:metadata.db_path.c_str() encoding:NSUTF8StringEncoding];
		self->_smallestSeqno = metadata.smallest_seqno;
		self->_largestSeqno = metadata.largest_seqno;
		self->_smallestKey = [NSString stringWithCString:metadata.smallestkey.c_str() encoding:NSUTF8StringEncoding];
		self->_largestKey = [NSString stringWithCString:metadata.largestkey.c_str() encoding:NSUTF8StringEncoding];
		self->_beingCompacted = metadata.being_compacted;
	}
	return self;
}

@end
