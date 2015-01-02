//
//  RocksDBTableFactory.m
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBTableFactory.h"

#import <rocksdb/table.h>

@interface RocksDBBlockBasedTableOptions ()
@property (nonatomic, assign) rocksdb::BlockBasedTableOptions options;
@end

@interface RocksDBTableFactory ()
{
	rocksdb::TableFactory *_tableFactory;
}
@property (nonatomic, assign) rocksdb::TableFactory *tableFactory;
@end

@implementation RocksDBTableFactory
@synthesize tableFactory = _tableFactory;

+ (instancetype)blockBasedTableFactoryWithOptions:(void (^)(RocksDBBlockBasedTableOptions *options))optionsBlock
{
	RocksDBBlockBasedTableOptions *options = [RocksDBBlockBasedTableOptions new];
	if (optionsBlock) {
		optionsBlock(options);
	}

	RocksDBTableFactory *instance = [[RocksDBTableFactory alloc] initWithNativeTableFacotry:rocksdb::NewBlockBasedTableFactory(options.options)];
	return instance;
}

- (instancetype)initWithNativeTableFacotry:(rocksdb::TableFactory *)tableFactory
{
	self = [super init];
	if (self) {
		_tableFactory = tableFactory;
	}
	return self;
}

@end
