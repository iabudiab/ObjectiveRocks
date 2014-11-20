//
//  BCRocks.h
//  BCRocks
//
//  Created by Iska on 15/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBOptions.h"

@interface RocksDB : NSObject

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path andOptions:(void (^)(RocksDBOptions *options))options;

- (void)close;

- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey;
- (BOOL)setData:(NSData *)data forKey:(NSData *)aKey error:(NSError **)error;

- (BOOL)setObject:(id)anObject forKey:(id)aKey;
- (BOOL)setObject:(id)anObject forKey:(id)aKey error:(NSError **)error;

@end
