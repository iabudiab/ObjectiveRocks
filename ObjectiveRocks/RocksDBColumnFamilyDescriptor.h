//
//  RocksDBColumnFamilyDescriptor.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBColumnFamilyOptions.h"

@interface RocksDBColumnFamilyDescriptor : NSObject

- (void)addColumnFamilyWithName:(NSString *)name andOptions:(void (^)(RocksDBColumnFamilyOptions *options))options;

@end
