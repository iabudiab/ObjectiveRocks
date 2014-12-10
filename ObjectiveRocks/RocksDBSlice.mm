//
//  RocksDBSlice.m
//  ObjectiveRocks
//
//  Created by Iska on 10/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBSlice.h"

#import <rocksdb/slice.h>

rocksdb::Slice SliceFromData(NSData *data)
{
	return rocksdb::Slice((char *)data.bytes, data.length);
}

NSData * DataFromSlice(rocksdb::Slice slice)
{
	return [NSData dataWithBytes:slice.data() length:slice.size()];
}
