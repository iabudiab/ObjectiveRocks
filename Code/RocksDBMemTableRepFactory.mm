//
//  RocksDBMemTableRepFactory.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBMemTableRepFactory.h"

#import <rocksdb/memtablerep.h>

@interface RocksDBMemTableRepFactory ()
{
	rocksdb::MemTableRepFactory *_memTableRepFactory;
}
@property (nonatomic, assign) rocksdb::MemTableRepFactory *memTableRepFactory;
@end

@implementation RocksDBMemTableRepFactory
@synthesize memTableRepFactory = _memTableRepFactory;

+ (instancetype)skipListRepFacotry
{
	return [[self alloc] initWithNatviceMemTableRepFactory:new rocksdb::SkipListFactory];
}

#ifndef ROCKSDB_LITE

+ (instancetype)vectorRepFactory
{
	return [[self alloc] initWithNatviceMemTableRepFactory:new rocksdb::VectorRepFactory];
}

+ (instancetype)hashSkipListRepFactory
{
	return [[self alloc] initWithNatviceMemTableRepFactory:rocksdb::NewHashSkipListRepFactory()];
}

+ (instancetype)hashLinkListRepFactory
{
	return [[self alloc] initWithNatviceMemTableRepFactory:rocksdb::NewHashLinkListRepFactory()];
}

+ (instancetype)hashCuckooRepFactoryWithWriteBufferSize:(size_t)writeBufferSize
{
	return [[self alloc] initWithNatviceMemTableRepFactory:rocksdb::NewHashCuckooRepFactory(writeBufferSize)];
}

#endif

- (instancetype)initWithNatviceMemTableRepFactory:(rocksdb::MemTableRepFactory *)factory
{
	self = [super init];
	if (self) {
		_memTableRepFactory = factory;
	}
	return self;
}

- (void)dealloc
{
	@synchronized(self) {
		if (_memTableRepFactory != nullptr) {
			delete _memTableRepFactory;
			_memTableRepFactory = nullptr;
		}
	}
}

@end
