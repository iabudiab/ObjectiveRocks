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

@interface RocksDB : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path andDBOptions:(void (^)(RocksDBOptions *options))options;

- (void)setDefaultReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions
			  andWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error withWriteOptions:(void (^)(RocksDBWriteOptions *writeOptions))writeOptions;

- (NSData *)dataForKey:(NSData *)aKey;
- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error;
- (NSData *)dataForKey:(NSData *)aKey withReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;
- (NSData *)dataForKey:(NSData *)aKey error:(NSError **)error withReadOptions:(void (^)(RocksDBReadOptions *readOptions))readOptions;


- (void)close;

@end
