//
//  RocksDBMergeOperatorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 14/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBMergeOperatorTests : RocksDBTests {

	func testSwift_AssociativeMergeOperator() {
		let mergeOp = RocksDBMergeOperator(name: "operator") { (key, existing, value) -> AnyObject in
			var prev: UInt64 = 0
			if let existing = existing {
				(existing as AnyObject).getBytes(&prev, length: MemoryLayout<UInt64>.size)
			}
			var plus: UInt64 = 0
			(value as AnyObject).getBytes(&plus, length: MemoryLayout<UInt64>.size)

			var result: UInt64 = prev + plus
			return Data(bytes: UnsafePointer<UInt8>(&result), count: MemoryLayout<UInt64>.size)
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
		})

		var value: UInt64 = 1
		try! rocks.merge(Data(value), forKey: Data.from(string: "key 1"))

		value = 5
		try! rocks.merge(Data(value), forKey: Data.from(string: "key 1"))

		let res: UInt64 = Val(try! rocks.data(forKey: Data.from(string: "key 1")))

		XCTAssertTrue(res == 6);
	}

	func testSwift_AssociativeMergeOperator_NumberAdd_Encoded() {
		let mergeOp = RocksDBMergeOperator(name: "operator") { (key, existing, value) -> AnyObject in
			var val = (value as AnyObject).floatValue
			if let existing = existing {
				val = val! + (existing as AnyObject).floatValue
			}
			let result: NSNumber = NSNumber(value: val! as Float)
			return result
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
			options.keyType = .nsString

			options.valueEncoder = {
				(key, value) -> Data in
				let val = value.floatValue
				let data = Data(val)
				return data
			}

			options.valueDecoder = {
				(key, data) -> NSNumber in
				if (data == nil) {
					return Optional.none!
				}

				let value: Float = Val(data)
				return NSNumber(value: value as Float)
			}
		})

		try! rocks.merge(NSNumber(value: 100.541 as Float), forKey: "key 1")
		try! rocks.merge(NSNumber(value: 200.125 as Float), forKey: "key 1")

		let result: Float = try! (rocks.object(forKey: "key 1") as AnyObject).floatValue
		XCTAssertEqualWithAccuracy(result, Float(300.666), accuracy: Float(0.0001))
	}

	func testSwift_AssociativeMergeOperator_DictionaryPut_Encoded() {
		let mergeOp = RocksDBMergeOperator(name: "operator") { (key, existing, value) -> AnyObject in
			guard let existing = existing else {
				return value as AnyObject
			}

			(existing as AnyObject).addEntries(from: value as! [AnyHashable: Any])
			return existing as AnyObject
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
			options.keyType = .nsString
			options.valueType = .nsjsonSerializable
		})

		try! rocks.setObject(["key 1": "value 1"], forKey: "dict key")
		try! rocks.merge(["key 1": "value 1 new"], forKey: "dict key")
		try! rocks.merge(["key 2": "value 2"], forKey: "dict key")
		try! rocks.merge(["key 3": "value 3"], forKey: "dict key")
		try! rocks.merge(["key 4": "value 4"], forKey: "dict key")
		try! rocks.merge(["key 5": "value 5"], forKey: "dict key")

		let expected: NSDictionary = ["key 1" : "value 1 new",
			"key 2" : "value 2",
			"key 3" : "value 3",
			"key 4" : "value 4",
			"key 5" : "value 5"]

		XCTAssertEqual(try! rocks.object(forKey: "dict key") as! NSDictionary, expected)
	}

	func testSwift_MergeOperator_DictionaryUpdate_Encoded() {
		let mergeOp = RocksDBMergeOperator(name: "operator", partialMerge:
			{
				(key, leftOperand, rightOperand) -> String! in
				let left: NSString = leftOperand.components(separatedBy: ":")[0] as NSString
				let right: NSString = rightOperand.components(separatedBy: ":")[0] as NSString
				if left.isEqual(to: right as String) {
					return rightOperand
				}
				return Optional.none!

			},
			fullMerge: {
				(key, existing, operands) -> NSMutableDictionary! in

				let dict: NSMutableDictionary = existing as! NSMutableDictionary
				for op in operands as NSArray {
					let comp: NSArray = (op as AnyObject).components(separatedBy: ":")
					let action: NSString = comp[1] as! NSString
					if action.isEqual(to: "DELETE") {
						dict.removeObject(forKey: comp[0])
					} else {
						dict.setObject(comp[2], forKey: comp[0] as! NSString)
					}
				}
				return existing as! NSMutableDictionary
			})

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
			options.keyType = .nsString
			options.valueType = .nsjsonSerializable
		})

		let object = ["key 1" : "value 1",
			"key 2" : "value 2",
			"key 3" : "value 3"]

		try! rocks.setObject(object, forKey: "dict key")

		try! rocks.mergeOperation("key 1:UPDATE:value X", forKey: "dict key")
		try! rocks.mergeOperation("key 4:INSERT:value 4", forKey: "dict key")
		try! rocks.mergeOperation("key 2:DELETE", forKey: "dict key")
		try! rocks.mergeOperation("key 1:UPDATE:value 1 new", forKey: "dict key")

		let expected = ["key 1" : "value 1 new",
			"key 3" : "value 3",
			"key 4" : "value 4"];

		XCTAssertEqual(try! rocks.object(forKey: "dict key") as! NSDictionary as! [String : String], expected)
	}
}
