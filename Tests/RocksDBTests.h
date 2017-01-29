//
//  RocksDBTests.h
//  ObjectiveRocks
//
//  Created by Iska on 24/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveRocks.h"

#pragma mark - RocksDBDataConvertible

@interface NSString (DataConvertible)
- (instancetype)initWithData:(NSData *)data;
- (NSData *)data;
@end

@implementation NSString (DataConvertible)
- (instancetype)initWithData:(NSData *)data
{
	return [self initWithData:data encoding:NSUTF8StringEncoding];
}
- (NSData *)data
{
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}
@end

#pragma mark - Base

@interface RocksDBTests : XCTestCase
{
	NSString *_path;
	NSString *_backupPath;
	NSString *_restorePath;

	NSString *_chekpointPath_1;
	NSString *_chekpointPath_2;

	RocksDB *_rocks;
}
@end
