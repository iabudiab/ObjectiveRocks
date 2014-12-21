//
//  RocksDBMergeOperator.h
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RocksDBMergeOperator : NSObject

+ (instancetype)operatorWithName:(NSString *)name
						andBlock:(id (^)(id key, id existingValue, id value))block;

+ (instancetype)operatorWithName:(NSString *)name
			   partialMergeBlock:(NSString * (^)(id key, NSString *leftOperand, NSString *rightOperand))partialMergeBlock
				  fullMergeBlock:(id (^)(id key, id existingValue, NSArray *operandList))fullMergeBlock;

@end
