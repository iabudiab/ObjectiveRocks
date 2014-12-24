//
//  RocksDBTests.h
//  ObjectiveRocks
//
//  Created by Iska on 24/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ObjectiveRocks.h"

#define Data(x) [x dataUsingEncoding:NSUTF8StringEncoding]
#define Str(x)	[[NSString alloc] initWithData:x encoding:NSUTF8StringEncoding]

#define NumData(x) [NSData dataWithBytes:&x length:sizeof(x)]
#define Val(data, x) [data getBytes:&x length:sizeof(x)];

@interface RocksDBTests : XCTestCase
{
	NSString *_path;
	RocksDB *_rocks;
}
@end
