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
	return [[self alloc] initWithNativeMemTableRepFactory:new rocksdb::SkipListFactory];
}

#if !(defined(ROCKSDB_LITE) && defined(TARGET_OS_IPHONE))

+ (instancetype)vectorRepFactory
{
	return [[self alloc] initWithNativeMemTableRepFactory:new rocksdb::VectorRepFactory];
}

+ (instancetype)hashSkipListRepFactory
{
	return [[self alloc] initWithNativeMemTableRepFactory:rocksdb::NewHashSkipListRepFactory()];
}

+ (instancetype)hashLinkListRepFactory
{
	return [[self alloc] initWithNativeMemTableRepFactory:rocksdb::NewHashLinkListRepFactory()];
}

#endif

- (instancetype)initWithNativeMemTableRepFactory:(rocksdb::MemTableRepFactory *)factory
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
