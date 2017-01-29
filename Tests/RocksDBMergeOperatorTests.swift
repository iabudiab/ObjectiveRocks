//
//  RocksDBMergeOperatorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 14/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

protocol DataConvertible {
	init?(data: Data)
	var data: Data { get }
}

extension DataConvertible {
	init?(data: Data) {
		guard data.count == MemoryLayout<Self>.size else {
			return nil
		}
		self = data.withUnsafeBytes { $0.pointee }
	}
	var data: Data {
		var value = self
		return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
	}
}

extension Int : DataConvertible { }
extension Double : DataConvertible { }

extension Dictionary {

	var data: Data {
		return try! JSONSerialization.data(withJSONObject: self, options: [])
	}

	mutating func update(with dict: Dictionary<Key, Value>) {
		for (key, value) in dict {
			self.updateValue(value, forKey: key)
		}
	}
}

extension Dictionary {
	static func from(data: Data) -> [String: Any] {
		return try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
	}
}

class RocksDBMergeOperatorTests : RocksDBTests {

	func testSwift_AssociativeMergeOperator() {

		let mergeOp = RocksDBMergeOperator(name: "operator") { (key, existing, value) -> Data in
			let prev: Int
			if let existing = existing {
				prev = Int(data: existing) ?? 0
			} else {
				prev = 0
			}

			let plus = Int(data: value)!
			return (prev + plus).data
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
		})

		try! rocks.merge(1.data, forKey: "key 1")
		try! rocks.merge(5.data, forKey: "key 1")

		let data = try! rocks.data(forKey: "key 1")
		let res = Int(data: data)!
		XCTAssertEqual(res, 6)
	}

	func testSwift_AssociativeMergeOperator_NumberAdd() {
		let mergeOp = RocksDBMergeOperator(name: "operator") { (key, existing, value) -> Data in
			let prev: Double
			if let existing = existing {
				prev = Double(data: existing) ?? 0
			} else {
				prev = 0
			}

			let plus = Double(data: value)!
			return (prev + plus).data
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
		})

		try! rocks.merge(100.541.data, forKey: "key 1")
		try! rocks.merge(200.125.data, forKey: "key 1")

		let data = try! rocks.data(forKey: "key 1")
		let res = Double(data: data)!
		XCTAssertEqualWithAccuracy(res, Double(300.666), accuracy: Double(0.0001))
	}

	func testSwift_AssociativeMergeOperator_DictionaryPut() {

		let mergeOp = RocksDBMergeOperator(name: "operator") { (key, existing, value) -> Data in
			guard let existing = existing else {
				return value
			}

			var dict = Dictionary<String, Any>.from(data: existing)
			let new = Dictionary<String, Any>.from(data: value)
			dict.update(with: new)
			return dict.data
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
		})

		try! rocks.setData(["key 1": "value 1"].data, forKey: "dict key")
		try! rocks.merge(["key 1": "value 1 new"].data, forKey: "dict key")
		try! rocks.merge(["key 2": "value 2"].data, forKey: "dict key")
		try! rocks.merge(["key 3": "value 3"].data, forKey: "dict key")
		try! rocks.merge(["key 4": "value 4"].data, forKey: "dict key")
		try! rocks.merge(["key 5": "value 5"].data, forKey: "dict key")

		let expected: [String: Any] = ["key 1" : "value 1 new",
		                               "key 2" : "value 2",
		                               "key 3" : "value 3",
		                               "key 4" : "value 4",
		                               "key 5" : "value 5"]

		let data = try! rocks.data(forKey: "dict key")
		let actual = Dictionary<String, Any>.from(data: data)
		for (key, value) in actual {
			XCTAssertEqual(value as! String, expected[key] as! String)
		}
	}

	func testSwift_MergeOperator_DictionaryUpdate() {

		let partial = { (key: Data, leftOperand: Data, rightOperand: Data) -> Data? in
			let left = String(data: leftOperand, encoding: .utf8)!.components(separatedBy: ":")[0]
			let right = String(data: rightOperand, encoding: .utf8)!.components(separatedBy: ":")[0]
			if left == right {
				return rightOperand
			}
			return nil
		}

		let full = { (key: Data, existing: Data?, operands: [Data]) -> Data? in
			var dict: [String: Any] = [:]
			if let existing = existing {
				dict = Dictionary<String, Any>.from(data: existing)
			}

			for op in operands {
				let comp = String(data: op, encoding: .utf8)!.components(separatedBy: ":")
				let action = comp[1]
				if action == "DELETE" {
					dict.removeValue(forKey: comp[0])
				} else {
					dict[comp[0]] = comp[2]
				}
			}
			return dict.data
		}

		let mergeOp = RocksDBMergeOperator(name: "operator", partialMerge: partial, fullMerge: full)

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = mergeOp
		})

		let object: [String: Any] = ["key 1" : "value 1",
		                             "key 2" : "value 2",
		                             "key 3" : "value 3"]

		try! rocks.setData(object.data, forKey: "dict key")

		try! rocks.merge("key 1:UPDATE:value X", forKey: "dict key")
		try! rocks.merge("key 4:INSERT:value 4", forKey: "dict key")
		try! rocks.merge("key 2:DELETE", forKey: "dict key")
		try! rocks.merge("key 1:UPDATE:value 1 new", forKey: "dict key")

		let expected: [String: Any] = ["key 1" : "value 1 new",
		                               "key 3" : "value 3",
		                               "key 4" : "value 4"];

		let data = try! rocks.data(forKey: "dict key")
		let actual = Dictionary<String, Any>.from(data: data)
		for (key, value) in actual {
			XCTAssertEqual(value as! String, expected[key] as! String)
		}
	}
}
