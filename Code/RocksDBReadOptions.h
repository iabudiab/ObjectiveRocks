//
//  RocksDBReadOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 20/11/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Options that control read operations. */
@interface RocksDBReadOptions : NSObject <NSCopying> 

/** @brief If true, all data read from underlying storage will be
 verified against corresponding checksums.
 Default: true
 */
@property (nonatomic, assign) BOOL verifyChecksums;

/** @brief If true, the "data block"/"index block"/"filter block" read for this
 iteration will be cached in memory. Callers may wish to set this field to false 
 for bulk scans.
 Default: true
 */
@property (nonatomic, assign) BOOL fillCache;

@end

NS_ASSUME_NONNULL_END
