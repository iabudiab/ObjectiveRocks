//
//  RocksDBTypes.h
//  ObjectiveRocks
//
//  Created by Iska on 25/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The predefined supported types */
typedef NS_ENUM(NSUInteger, RocksDBType)
{
	/** @brief Type for keys/values that are NSString objects. */
	RocksDBTypeNSString,
	/** @brief Type for keys/values that are serializable via 
	 the NSJSONSerialization. */
	RocksDBTypeNSJSONSerializable
};

/** Utility class for the predefined key/value encoders. */
@interface RocksDBTypes : NSObject

/** 
 Returns a predefined key encoder for the given type.

 @param type The predefined type.
 @return The predefined key encoder.
 */
+ (NSData *(^)(id))keyEncoderForType:(RocksDBType)type;

/**
 Returns a predefined key decoder for the given type.

 @param type The predefined type.
 @return The predefined key decoder.
 */
+ (id (^)(NSData *))keyDecoderForType:(RocksDBType)type;


/**
 Returns a predefined value decoder for the given type.

 @param type The predefined type.
 @return The predefined value decoder.
 */
+ (NSData *(^)(id, id))valueEncoderForType:(RocksDBType)type;

/**
 Returns a predefined value decoder for the given type.

 @param type The predefined type.
 @return The predefined value decoder.
 */
+ (id (^)(id, NSData *))valueDecoderForType:(RocksDBType)type;

@end
