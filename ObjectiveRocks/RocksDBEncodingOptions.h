//
//  RocksDBEncodingOptions.h
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBTypes.h"

@interface RocksDBEncodingOptions : NSObject

@property (nonatomic, copy) NSData * (^ keyEncoder)(id key);
@property (nonatomic, copy) id (^ keyDecoder)(NSData *data);
@property (nonatomic, copy) NSData * (^ valueEncoder)(id key, id value);
@property (nonatomic, copy) id (^ valueDecoder)(id key, NSData *data);

@property (nonatomic, assign) RocksDBType keyType;
@property (nonatomic, assign) RocksDBType valueType;

@end
