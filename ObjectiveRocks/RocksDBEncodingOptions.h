//
//  RocksDBEncodingOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBTypes.h"

/**
 Options to define how arbitrary objects (keys & values) should be converted to
 NSData and vise versa.
 */
@interface RocksDBEncodingOptions : NSObject

/** @brief
 A block to convert `id` keys to NSData objects.
 */
@property (nonatomic, copy) NSData * (^ keyEncoder)(id key);

/** @brief
 A block to convert NSData objects to the corresponding `id` key.
 */
@property (nonatomic, copy) id (^ keyDecoder)(NSData *data);

/** @brief
 A block to convert `id` values to NSData objects. The block takes two
 parameters, the key-value pair to allow multiplexing.
 */
@property (nonatomic, copy) NSData * (^ valueEncoder)(id key, id value);

/** @brief A block to convert NSData objects to the corresponding value. */
@property (nonatomic, copy) id (^ valueDecoder)(id key, NSData *data);

/** @brief Use a predefined type for the keys.
 @see RocksDBTypes
 */
@property (nonatomic, assign) RocksDBType keyType;

/** @brief Use a predefined type for the values.
 @see RocksDBTypes
 */
@property (nonatomic, assign) RocksDBType valueType;

@end
