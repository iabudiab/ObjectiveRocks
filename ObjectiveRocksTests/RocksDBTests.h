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
	NSString *_backupPath;
	NSString *_restorePath;
	RocksDB *_rocks;
}
@end

@interface NSMutableArray (Shuffle)
- (void)shuffle;
@end

@implementation NSMutableArray (Shuffle)

- (void)shuffle
{
	NSUInteger count = [self count];
	for (NSUInteger i = 0; i < count; ++i) {
		NSInteger remainingCount = count - i;
		NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
		[self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
	}
}

@end