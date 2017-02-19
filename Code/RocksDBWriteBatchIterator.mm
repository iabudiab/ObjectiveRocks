//
//  RocksDBWriteBatchIterator.m
//  ObjectiveRocks
//
//  Created by Iska on 20/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import "RocksDBWriteBatchIterator.h"
#import "RocksDBSlice.h"

#import <rocksdb/utilities/write_batch_with_index.h>

@interface RocksDBWriteBatchEntry (Private)
@property (nonatomic, assign) RocksDBWriteBatchEntryType type;
@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@end

@implementation RocksDBWriteBatchEntry
@synthesize type;
@synthesize key;
@synthesize value;
@end

@interface RocksDBWriteBatchIterator ()
{
	rocksdb::WBWIIterator *_iterator;
}
@end

@implementation RocksDBWriteBatchIterator

#pragma mark - Lifecycle

- (instancetype)initWithWriteBatchIterator:(rocksdb::WBWIIterator *)iterator
{
	self = [super init];
	if (self) {
		_iterator = iterator;
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
		if (_iterator != nullptr) {
			delete _iterator;
			_iterator = nullptr;
		}
	}
}

#pragma mark - Operations

- (BOOL)isValid
{
	return _iterator->Valid();
}

- (void)seekToFirst
{
	_iterator->SeekToFirst();
}

- (void)seekToLast
{
	_iterator->SeekToLast();
}

- (void)seekToKey:(NSData *)aKey
{
	if (aKey != nil) {
		_iterator->Seek(SliceFromData(aKey));
	}
}

- (void)next
{
	_iterator->Next();
}

- (void)previous
{
	_iterator->Prev();
}

- (RocksDBWriteBatchEntry *)entry
{
	rocksdb::WriteEntry nativeEntry = _iterator->Entry();
	RocksDBWriteBatchEntry *writeEntry = [RocksDBWriteBatchEntry new];
	writeEntry.type = (RocksDBWriteBatchEntryType)nativeEntry.type;
	writeEntry.key = DataFromSlice(nativeEntry.key);
	writeEntry.value = DataFromSlice(nativeEntry.value);
	return writeEntry;
}

#pragma mark - Enumeration

- (void)enumerateEntriesUsingBlock:(void (^)(RocksDBWriteBatchEntry *entry, BOOL *stop))block
{
	BOOL stop = NO;

	for (_iterator->SeekToFirst(); _iterator->Valid(); _iterator->Next()) {
		if (block) block(self.entry, &stop);
		if (stop == YES) break;
	}
}

- (void)reverseEnumerateEntriesUsingBlock:(void (^)(RocksDBWriteBatchEntry *entry, BOOL *stop))block
{
	BOOL stop = NO;

	for (_iterator->SeekToLast(); _iterator->Valid(); _iterator->Prev()) {
		if (block) block(self.entry, &stop);
		if (stop == YES) break;
	}
}

@end
