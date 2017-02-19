//
//  RocksDBPrefixExtractor.h
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Constants for the built-in prefix extractors.
 */
typedef NS_ENUM(NSUInteger, RocksDBPrefixType)
{
	/** @brief Extract a fixed-length prefix for each key. */
	RocksDBPrefixFixedLength
};

/**
 `RocksDBIterator` supports iterating inside a key-prefix by providing a `RocksDBPrefixExtractor`.

 The `RocksDBPrefixExtractor` defines a Slice-Transform function that is applied to each key when 
 itarating the DB in order to extract the prefix for the prefix-seek API.
 */
@interface RocksDBPrefixExtractor : NSObject

/**
 Intializes a new instance of the prefix extarctor with the given type and length.
 
 @param type The type of the prefix extractor.
 @param length The length of the desired prefix.
 @return A newly-initialized instance of a prefix extractor.
 */
+ (instancetype)prefixExtractorWithType:(RocksDBPrefixType)type length:(size_t)length;

/**
 Intializes a new instance of the prefix extarctor with the given transformation functions.

 @param transformBlock A block to apply to each key to extract the prefix.
 @param prefixCandidateBlock A block that is applied to each key before the transformation 
 in order to filter out keys that are not viable candidates for the custom prefix format, 
 e.g. key length is smaller than the target prefix length.
 @param validPrefixBlock A block that is applied to each key after the transformation in
 order to perform extra checks to verify that the extracted prefix is valid.
 @return A newly-initialized instance of a prefix extractor.
 */
- (instancetype)initWithName:(NSString *)name
			  transformBlock:(NSData * (^)(NSData *key))transformBlock
		prefixCandidateBlock:(BOOL (^)(NSData *key))prefixCandidateBlock
			validPrefixBlock:(BOOL (^)(NSData *prefix))validPrefixBlock;

@end

NS_ASSUME_NONNULL_END
