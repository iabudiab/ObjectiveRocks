//
//  RocksDBMergeOperator.h
//  ObjectiveRocks
//
//  Created by Iska on 07/12/14.
//  Copyright (c) 2014 BrainCookie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 
 A Merge operator is an atomic Read-Modify-Write operation in RocksDB.
 */
@interface RocksDBMergeOperator : NSObject

/**
 Initializes a new instance of an associative merge operator.

 @discussion This Merge Operator can be use for associative data:

 * The merge operands are formatted the same as the Put values, AND
 * It is okay to combine multiple operands into one (as long as they are in the same order)

 @param name The name of the merge operator.
 @param block The block that merges the existing and new values for the given key.
 @return A newly-initialized instance of the Merge Operator.
 */
+ (instancetype)operatorWithName:(NSString *)name
						andBlock:(id (^)(id key, id _Nullable existingValue, id value))block;

/**
 Initializes a new instance of a generic merge operator.

 @discussion If either of the two associativity constraints do not hold, then the Generic Merge Operator could
 be used.

 The Generic Merge Operator has two methods, PartialMerge, FullMerge:

 * PartialMerge: used to combine two-merge operands (if possible). If the client-specified operator can logically 
 handle “combining” two merge-operands into a single operand, the semantics for doing so should be provided in this 
 method, which should then return a non-nil object. If `nil` is returned, then it means that the two merge-operands
 couldn’t be combined into one.

 * FullMerge: this function is given an existingValue and a list of operands that have been stacked. The 
 client-specified MergeOperator should then apply the operands one-by-one and return the resulting object. 
 If `nil` is returned, then this indicates a failure, i.e. corrupted data, errors ... etc.

 @param name The name of the merge operator.
 @param partialMergeBlock The block to perform a partial merge.
 @param fullMergeBlock The block to perform the full merge.
 @return A newly-initialized instance of the Merge Operator.
 */
+ (instancetype)operatorWithName:(NSString *)name
			   partialMergeBlock:(NSString * _Nullable (^)(id key, NSString *leftOperand, NSString *rightOperand))partialMergeBlock
				  fullMergeBlock:(id _Nullable (^)(id key, id _Nullable existingValue, NSArray *operandList))fullMergeBlock;

@end

NS_ASSUME_NONNULL_END
