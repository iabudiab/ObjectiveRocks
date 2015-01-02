//
//  RocksDBEncodingOptions.m
//  ObjectiveRocks
//
//  Created by Iska on 29/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBEncodingOptions.h"

@implementation RocksDBEncodingOptions

- (void)setKeyType:(RocksDBType)type
{
	self.keyEncoder = [RocksDBTypes keyEncoderForType:type];
	self.keyDecoder = [RocksDBTypes keyDecoderForType:type];
	_keyType = type;
}

- (void)setValueType:(RocksDBType)type
{
	self.valueEncoder = [RocksDBTypes valueEncoderForType:type];
	self.valueDecoder = [RocksDBTypes valueDecoderForType:type];
	_valueType = type;
}

@end
