//
//  RocksDBColumnFamilyMetaData.h
//  ObjectiveRocks
//
//  Created by Iska on 09/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The metadata that describes a Column Family.
 */
@interface RocksDBColumnFamilyMetaData : NSObject

/** 
 @brief The size of this Column Family in bytes, which is equal to the sum of the file size of its "levels".
 */
@property (nonatomic, assign) uint64_t size;

/**
 @brief The number of files in this Clumn Family.
 */
@property (nonatomic, assign) size_t fileCount;

/**
 @brief The name of the Column Family.
 */
@property (nonatomic, assign) NSString *name;

/**
 @brief The metadata of all levels in this Column Family.
 */
@property (nonatomic, strong, readonly) NSArray *levels;

@end

/**
 The metadata that describes a level.
 */
@interface RocksDBLevelFileMetaData : NSObject

/**
 @brief The level which this meta data describes.
 */
@property (nonatomic, assign) const int level;

/** 
 @brief The size of this level in bytes, which is equal to the sum of the file size of its "files".
 */
@property (nonatomic, assign) const uint64_t size;

/**
 @brief The metadata of all sst files in this level.
 */
@property (nonatomic, strong, readonly) NSArray *files;

@end

/**
 The metadata that describes a SST file.
 */
@interface RocksDBSstFileMetaData : NSObject

/**
 @brief File size in bytes.
 */
@property (nonatomic, assign) uint64_t size;

/**
 @brief The name of the file.
 */
@property (nonatomic, assign) NSString *name;

/**
 @brief The full path where the file locates.
 */
@property (nonatomic, assign) NSString *dbPath;

/**
 @brief Smallest sequence number in file.
 */
@property (nonatomic, assign) uint64_t smallestSeqno;

/**
 @brief Largest sequence number in file.
 */
@property (nonatomic, assign) uint64_t largestSeqno;

/**
 @brief Smallest user defined key in the file.
 */
@property (nonatomic, assign) NSString *smallestKey;

/**
 @brief Largest user defined key in the file.
 */
@property (nonatomic, assign) NSString *largestKey;

/**
 @brief `true` if the file is currently being compacted.
 */
@property (nonatomic, assign) bool beingCompacted;

@end
