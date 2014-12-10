//
//  RocksDBSlice.h
//  ObjectiveRocks
//
//  Created by Iska on 10/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <string>

namespace rocksdb {
	class Slice;
}

NS_INLINE rocksdb::Slice SliceFromData(NSData *data);
NS_INLINE NSData * DataFromSlice(rocksdb::Slice slice);
