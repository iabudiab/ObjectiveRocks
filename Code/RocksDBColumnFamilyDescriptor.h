//
//  RocksDBColumnFamilyDescriptor.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBColumnFamilyOptions.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const RocksDBDefaultColumnFamilyName;

/**
 When opening a DB in a read-write mode, all Column Families that currently exist in a DB must be specified via
 a `RocksDBColumnFamilyDescriptor` instance, which should hold the names and the desired options for the Column
 Families.
 */
@interface RocksDBColumnFamilyDescriptor : NSObject

/**
 Adds the default Column Family to this descriptor instance with the given options.

 @param options A block for specifying the options for the default Column Family.

 @see RocksDBColumnFamilyOptions
 */
- (void)addDefaultColumnFamilyWithOptions:(nullable void (^)(RocksDBColumnFamilyOptions *options))options;

/**
 Adds a Column Family to this descriptor instance with the given name and options.

 @param name The name of the Column Family.
 @param options A block for specifying the options for the Column Family.

 @see RocksDBColumnFamilyOptions
 */
- (void)addColumnFamilyWithName:(NSString *)name andOptions:(nullable void (^)(RocksDBColumnFamilyOptions *options))options;

@end

NS_ASSUME_NONNULL_END
