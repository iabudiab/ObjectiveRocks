//
//  BCRocks.h
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBOptions.h"
#import "RocksDBReadOptions.h"
#import "RocksDBWriteOptions.h"
#import "RocksDBWriteBatch.h"
#import "RocksDBIterator.h"

@interface RocksDB : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path andDBOptions:(void (^)(RocksDBOptions *options))options;

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (NSData *)dataForKey:(NSData *)aKey;
- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error;
- (NSData *)dataForKey:(NSData *)aKey readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;
- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error readOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;

- (BOOL)deleteDataForKey:(NSData *)aKey;
- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error;
- (BOOL)deleteDataForKey:(NSData *)aKey writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)deleteDataForKey:(NSData *)aKey error:(NSError **)error writeOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch;
- (BOOL)performWriteBatch:(void (^)(RocksDBWriteBatch *batch, RocksDBWriteOptions *options))batch error:(NSError **)error;

- (RocksDBIterator *)iterator;
- (RocksDBIterator *)iteratorWithReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;

- (void)close;

@end
