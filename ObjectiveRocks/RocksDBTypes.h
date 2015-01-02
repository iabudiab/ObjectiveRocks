//
//  RocksDBTypes.h
//  ObjectiveRocks
//
//  Created by Iska on 25/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RocksDBType)
{
	RocksDBTypeNSString,
	RocksDBTypeNSJSONSerializable
};

@interface RocksDBTypes : NSObject

+ (NSData *(^)(id))keyEncoderForType:(RocksDBType)type;
+ (id (^)(NSData *))keyDecoderForType:(RocksDBType)type;

+ (NSData *(^)(id, id))valueEncoderForType:(RocksDBType)type;
+ (id (^)(id, NSData *))valueDecoderForType:(RocksDBType)type;

@end
