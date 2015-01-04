//
//  RocksDBPlainTableOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 04/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, PlainTableEncodingType)
{
	PlainTableEncodingPlain,
	PlainTableEncodingPrefix
};

@interface RocksDBPlainTableOptions : NSObject

@property (nonatomic, assign) uint32_t userKeyLen;
@property (nonatomic, assign) int bloomBitsPerKey;
@property (nonatomic, assign) double hashTableRatio;
@property (nonatomic, assign) size_t indexSparseness;
@property (nonatomic, assign) size_t hugePageTlbSize;
@property (nonatomic, assign) PlainTableEncodingType encodingType;
@property (nonatomic, assign) BOOL fullScanMode;
@property (nonatomic, assign) BOOL storeIndexInFile;

@end
