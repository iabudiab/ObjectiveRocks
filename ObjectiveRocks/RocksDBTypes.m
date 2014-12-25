//
//  RocksDBTypes.m
//  ObjectiveRocks
//
//  Created by Iska on 25/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import "RocksDBTypes.h"

@implementation RocksDBTypes

+ (NSData *(^)(id))keyEncoderForType:(RocksDBType)type
{
	switch (type) {
		case RocksDBTypeNSString:
			return ^NSData * (id key) {
				return [key dataUsingEncoding:NSUTF8StringEncoding];
			};

		case RocksDBTypeNSJSONSerializable:
			return ^NSData * (id key) {
				NSError *error = nil;
				NSData *data = [NSJSONSerialization dataWithJSONObject:key
															   options:0
																 error:&error];
				if (error) {
					NSLog(@"Error encoding key: %@", error.debugDescription);
				}
				return data;
			};
	}
}

+ (id (^)(NSData *))keyDecoderForType:(RocksDBType)type
{
	switch (type) {
		case RocksDBTypeNSString:
			return ^id (NSData *data) {
				if (data == nil) return nil;
				return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			};

		case RocksDBTypeNSJSONSerializable:
			return ^id (NSData * data) {
				if (data == nil) return nil;
				NSError *error = nil;
				id obj = [NSJSONSerialization JSONObjectWithData:data
														 options:NSJSONReadingMutableContainers
														   error:&error];
				if (error) {
					NSLog(@"Error decoding key: %@", error.debugDescription);
				}
				return obj;
			};
	}
}

+ (NSData *(^)(id, id))valueEncoderForType:(RocksDBType)type
{
	switch (type) {
		case RocksDBTypeNSString:
			return ^NSData * (id key, id value) {
				return [value dataUsingEncoding:NSUTF8StringEncoding];
			};

		case RocksDBTypeNSJSONSerializable:
			return ^NSData * (id key, id value) {
				NSError *error = nil;
				NSData *data = [NSJSONSerialization dataWithJSONObject:value
															   options:0
																 error:&error];
				if (error) {
					NSLog(@"Error encoding value: %@", error.debugDescription);
				}
				return data;
			};

	}
}

+ (id (^)(id, NSData *))valueDecoderForType:(RocksDBType)type
{
	switch (type) {
		case RocksDBTypeNSString:
			return ^id (id key, NSData *data) {
				if (data == nil) return nil;
				return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			};

		case RocksDBTypeNSJSONSerializable:
			return ^id (id key, NSData * data) {
				if (data == nil) return nil;
				NSError *error = nil;
				id obj = [NSJSONSerialization JSONObjectWithData:data
														 options:NSJSONReadingMutableContainers
														   error:&error];
				if (error) {
					NSLog(@"Error decoding value: %@", error.debugDescription);
				}
				return obj;
			};
	}
}

@end
