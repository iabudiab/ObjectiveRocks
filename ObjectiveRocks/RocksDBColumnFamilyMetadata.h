//
//  RocksDBColumnFamilyMetaData.h
//  ObjectiveRocks
//
//  Created by Iska on 09/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBColumnFamilyMetaData : NSObject

@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) size_t fileCount;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, strong, readonly) NSArray *levels;

@end

@interface RocksDBLevelFileMetaData : NSObject

@property (nonatomic, assign) const int level;
@property (nonatomic, assign) const uint64_t size;
@property (nonatomic, strong, readonly) NSArray *files;

@end

@interface RocksDBSstFileMetaData : NSObject

@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSString *dbPath;
@property (nonatomic, assign) uint64_t smallestSeqno;
@property (nonatomic, assign) uint64_t largestSeqno;
@property (nonatomic, assign) NSString *smallestKey;
@property (nonatomic, assign) NSString *largestKey;
@property (nonatomic, assign) bool beingCompacted;

@end
