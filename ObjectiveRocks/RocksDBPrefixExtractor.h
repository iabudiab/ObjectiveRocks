//
//  RocksDBPrefixExtractor.h
//  ObjectiveRocks
//
//  Created by Iska on 26/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RocksDBPrefixType)
{
	RocksDBPrefixFixedLength
};

@interface RocksDBPrefixExtractor : NSObject

+ (instancetype)prefixExtractorWithType:(RocksDBPrefixType)type length:(size_t)length;

- (instancetype)initWithName:(NSString *)name
			  transformBlock:(id (^)(id key))transformBlock
		prefixCandidateBlock:(BOOL (^)(id key))prefixCandidateBlock
			validPrefixBlock:(BOOL (^)(id prefix))validPrefixBlock;

@end
