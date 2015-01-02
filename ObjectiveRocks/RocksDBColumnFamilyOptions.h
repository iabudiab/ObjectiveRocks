//
//  RocksDBColumnFamilyOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 28/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBComparator.h"
#import "RocksDBMergeOperator.h"
#import "RocksDBPrefixExtractor.h"
#import "RocksDBTypes.h"

typedef NS_ENUM(char, RocksDBCompressionType)
{
	RocksDBCompressionNone = 0x0,
	RocksDBCompressionSnappy = 0x1,
	RocksDBCompressionZlib = 0x2,
	RocksDBCompressionBZip2 = 0x3,
	RocksDBCompressionLZ4 = 0x4,
	RocksDBCompressionLZ4HC = 0x5
};

@interface RocksDBColumnFamilyOptions : NSObject

@property (nonatomic, strong) RocksDBComparator *comparator;
@property (nonatomic, strong) RocksDBMergeOperator *mergeOperator;
@property (nonatomic, strong) RocksDBPrefixExtractor *prefixExtractor;
@property (nonatomic, assign) size_t writeBufferSize;
@property (nonatomic, assign) int maxWriteBufferNumber;
@property (nonatomic, assign) RocksDBCompressionType compressionType;

@end

@interface RocksDBColumnFamilyOptions (Encoding)

@property (nonatomic, copy) NSData * (^ keyEncoder)(id key);
@property (nonatomic, copy) id (^ keyDecoder)(NSData *data);
@property (nonatomic, copy) NSData * (^ valueEncoder)(id key, id value);
@property (nonatomic, copy) id (^ valueDecoder)(id key, NSData *data);

@property (nonatomic, assign) RocksDBType keyType;
@property (nonatomic, assign) RocksDBType valueType;

@end
