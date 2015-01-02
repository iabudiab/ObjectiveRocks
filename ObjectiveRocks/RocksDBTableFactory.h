//
//  RocksDBTableFactory.h
//  ObjectiveRocks
//
//  Created by Iska on 02/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBBlockBasedTableOptions.h"

@interface RocksDBTableFactory : NSObject

+ (instancetype)blockBasedTableFactoryWithOptions:(void (^)(RocksDBBlockBasedTableOptions *options))options;

@end
