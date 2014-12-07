//
//  RocksDBWriteBatch.h
//  BCRocks
//
//  Created by Iska on 02/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBWriteBatch : NSObject

- (void)setData:(NSData *)data forKey:(NSData *)aKey;
- (void)deleteDataForKey:(NSData *)aKey;
- (void)clear;

- (int)count;
- (NSData *)data;
- (size_t)dataSize;

@end
