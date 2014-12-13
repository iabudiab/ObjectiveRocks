//
//  RocksDBSlice.h
//  ObjectiveRocks
//
//  Created by Iska on 10/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RocksDBOptions.h"
#import "ObjectiveRocksError.h"

#import <rocksdb/slice.h>

NS_INLINE rocksdb::Slice SliceFromData(NSData *data)
{
	return rocksdb::Slice((char *)data.bytes, data.length);
}

NS_INLINE NSData * DataFromSlice(rocksdb::Slice slice)
{
	return [NSData dataWithBytes:slice.data() length:slice.size()];
}

NS_INLINE NSData * EncodeKey(id aKey, RocksDBOptions *options, NSError * __autoreleasing *error)
{
	if ([aKey isKindOfClass:[NSData class]]) {
		return aKey;
	}

	NSData *encoded = nil;
	if (options.keyEncoder != nil) {
		encoded = options.keyEncoder(aKey);
	} else if (error && *error == nil) {
		NSError *temp = [ObjectiveRocksError errorForMissingConversionBlock];
		*error = temp;
	}
	return encoded;
}

NS_INLINE rocksdb::Slice SliceFromKey(id aKey, RocksDBOptions *options, NSError * __autoreleasing *error)
{
	return SliceFromData(EncodeKey(aKey, options, error));
}

NS_INLINE NSData * EncodeValue(id aKey, id value, RocksDBOptions *options, NSError * __autoreleasing *error)
{
	if ([value isKindOfClass:[NSData class]]) {
		return value;
	}

	NSData *encoded = nil;
	if (options.valueEncoder != nil) {
		encoded = options.valueEncoder(aKey, value);
	} else if (error && *error == nil) {
		NSError *temp = [ObjectiveRocksError errorForMissingConversionBlock];
		*error = temp;
	}
	return encoded;
}

NS_INLINE rocksdb::Slice SliceFromValue(id aKey, id value, RocksDBOptions *options, NSError * __autoreleasing *error)
{
	return SliceFromData(EncodeValue(aKey, value, options, error));
}

NS_INLINE id DecodeKeySlice(rocksdb::Slice slice, RocksDBOptions *options, NSError * __autoreleasing *error)
{
	id key = DataFromSlice(slice);
	if (options.keyDecoder != nil) {
		key = options.keyDecoder(key);
	} else if (error && *error == nil) {
		NSError *temp = [ObjectiveRocksError errorForMissingConversionBlock];
		*error = temp;
	}
	return key;
}
NS_INLINE id DecodeValueSlice(id aKey, rocksdb::Slice slice, RocksDBOptions *options, NSError * __autoreleasing *error)
{
	id value = DataFromSlice(slice);
	if (options.valueDecoder != nil) {
		value = options.valueDecoder(aKey, value);
	} else if (error && *error == nil) {
		NSError *temp = [ObjectiveRocksError errorForMissingConversionBlock];
		*error = temp;
	}
	return value;
}
