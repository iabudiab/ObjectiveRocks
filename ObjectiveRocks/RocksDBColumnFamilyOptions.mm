//
//  RocksDBColumnFamilyOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBColumnFamilyOptions.h"
#import "RocksDBEncodingOptions.h"

#import <rocksdb/options.h>
#import <rocksdb/comparator.h>
#import <rocksdb/merge_operator.h>
#import <rocksdb/slice_transform.h>
#import <rocksdb/table.h>

@class RocksDBOptions;

@interface RocksDBComparator ()
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
@property (nonatomic, assign) const rocksdb::Comparator *comparator;
@end

@interface RocksDBMergeOperator ()
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
@property (nonatomic, assign) rocksdb::MergeOperator *mergeOperator;
@end

@interface RocksDBPrefixExtractor ()
@property (nonatomic, strong) RocksDBEncodingOptions *encodingOptions;
@property (nonatomic, assign) const rocksdb::SliceTransform *sliceTransform;
@end

@interface RocksDBTableFactory ()
@property (nonatomic, assign) rocksdb::TableFactory *tableFactory;
@end

@interface RocksDBColumnFamilyOptions ()
{
	rocksdb::ColumnFamilyOptions _options;
	RocksDBEncodingOptions *_encodingOptions;

	RocksDBComparator *_comparatorWrapper;
	RocksDBMergeOperator *_mergeOperatorWrapper;
	RocksDBPrefixExtractor *_prefixExtractorWrapper;

	RocksDBTableFactory *_tableFactoryWrapper;
}
@property (nonatomic, assign) rocksdb::ColumnFamilyOptions options;
@end

@implementation RocksDBColumnFamilyOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_encodingOptions = [RocksDBEncodingOptions new];
		_options = rocksdb::ColumnFamilyOptions();
	}
	return self;
}

#pragma mark - Encoding Options

-(id) forwardingTargetForSelector:(SEL)aSelector
{
	if ([_encodingOptions respondsToSelector:aSelector]) {
		return _encodingOptions;
	}

	return nil;
}

#pragma mark - Column Family Options

- (void)setComparator:(RocksDBComparator *)comparator
{
	_comparatorWrapper = comparator;
	_comparatorWrapper.encodingOptions = _encodingOptions;
	_options.comparator = _comparatorWrapper.comparator;
}

- (RocksDBComparator *)comparator
{
	return _comparatorWrapper;
}

- (void)setMergeOperator:(RocksDBMergeOperator *)mergeOperator
{
	_mergeOperatorWrapper = mergeOperator;
	_mergeOperatorWrapper.encodingOptions = _encodingOptions;
	_options.merge_operator.reset(_mergeOperatorWrapper.mergeOperator);
}

- (RocksDBMergeOperator *)mergeOperator
{
	return _mergeOperatorWrapper;
}

- (void)setPrefixExtractor:(RocksDBPrefixExtractor *)prefixExtractor
{
	_prefixExtractorWrapper = prefixExtractor;
	_prefixExtractorWrapper.encodingOptions = _encodingOptions;
	_options.prefix_extractor.reset(_prefixExtractorWrapper.sliceTransform);
}

- (RocksDBPrefixExtractor *)prefixExtractor
{
	return _prefixExtractorWrapper;
}

- (size_t)writeBufferSize
{
	return _options.write_buffer_size;
}

- (void)setWriteBufferSize:(size_t)writeBufferSize
{
	_options.write_buffer_size = writeBufferSize;
}

- (int)maxWriteBufferNumber
{
	return _options.max_write_buffer_number;
}

- (void)setMaxWriteBufferNumber:(int)maxWriteBufferNumber
{
	_options.max_write_buffer_number = maxWriteBufferNumber;
}

- (RocksDBCompressionType)compressionType
{
	return (RocksDBCompressionType)_options.compression;
}

- (void)setCompressionType:(RocksDBCompressionType)compressionType
{
	_options.compression = (rocksdb::CompressionType)compressionType;
}

- (void)setTableFacotry:(RocksDBTableFactory *)tableFacotry
{
	_tableFactoryWrapper = tableFacotry;
	_options.table_factory.reset(_tableFactoryWrapper.tableFactory);
}

- (RocksDBTableFactory *)tableFacotry
{
	return _tableFactoryWrapper;
}

@end
