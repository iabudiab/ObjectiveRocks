//
//  RocksDBPlainTableOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBPlainTableOptions.h"

#import <rocksdb/table.h>

@interface RocksDBPlainTableOptions ()
{
	rocksdb::PlainTableOptions _options;
}
@property (nonatomic, assign) rocksdb::PlainTableOptions options;
@end

@implementation RocksDBPlainTableOptions
@synthesize options = _options;

#pragma mark - Lifecycle

- (instancetype)init
{
	self = [super init];
	if (self) {
		_options = rocksdb::PlainTableOptions();
	}
	return self;
}


#pragma mark - Accessor

- (void)setUserKeyLen:(uint32_t)userKeyLen
{
	_options.user_key_len = userKeyLen;
}

- (uint32_t)userKeyLen
{
	return _options.user_key_len;
}

- (void)setBloomBitsPerKey:(int)bloomBitsPerKey
{
	_options.bloom_bits_per_key = bloomBitsPerKey;
}

- (int)bloomBitsPerKey
{
	return _options.bloom_bits_per_key;
}

- (void)setHashTableRatio:(double)hashTableRatio
{
	_options.hash_table_ratio = hashTableRatio;
}

- (double)hashTableRatio
{
	return _options.hash_table_ratio;
}

- (void)setIndexSparseness:(size_t)indexSparseness
{
	_options.index_sparseness = indexSparseness;
}

- (size_t)indexSparseness
{
	return _options.index_sparseness;
}

- (void)setHugePageTlbSize:(size_t)hugePageTlbSize
{
	_options.huge_page_tlb_size = hugePageTlbSize;
}

- (size_t)hugePageTlbSize
{
	return _options.huge_page_tlb_size;
}

- (void)setEncodingType:(PlainTableEncodingType)encodingType
{
	_options.encoding_type = (rocksdb::EncodingType)encodingType;
}

- (PlainTableEncodingType)encodingType
{
	return (PlainTableEncodingType)_options.encoding_type;
}

- (void)setFullScanMode:(BOOL)fullScanMode
{
	_options.full_scan_mode = fullScanMode;
}

- (BOOL)fullScanMode
{
	return _options.full_scan_mode;
}

- (void)setStoreIndexInFile:(BOOL)storeIndexInFile
{
	_options.store_index_in_file = storeIndexInFile;
}

- (BOOL)storeIndexInFile
{
	return _options.store_index_in_file;
}

@end
