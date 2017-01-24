//
//  RocksDBComparatorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 12/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBComparatorTests : RocksDBTests {

	func testSwift_Comparator_Native_Bytewise_Ascending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .bytewiseAscending)
		})

		try! rocks.setData(Data.from(string: "abc1"), forKey: Data.from(string: "abc1"))
		try! rocks.setData(Data.from(string: "abc2"), forKey: Data.from(string: "abc2"))
		try! rocks.setData(Data.from(string: "abc3"), forKey: Data.from(string: "abc3"))

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc1"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc1"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc2"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc2"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc3"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc3"))

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc3"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc3"))

		iterator.seek(toKey: Data.from(string: "abc"))

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc1"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc1"))

		iterator.close()
	}

	func testSwift_Comparator_Native_Bytewise_Descending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .bytewiseDescending)
		})

		try! rocks.setData(Data.from(string: "abc1"), forKey: Data.from(string: "abc1"))
		try! rocks.setData(Data.from(string: "abc2"), forKey: Data.from(string: "abc2"))
		try! rocks.setData(Data.from(string: "abc3"), forKey: Data.from(string: "abc3"))

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc3"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc3"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc2"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc2"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc1"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc1"))

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc1"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc1"))

		iterator.seek(toKey: Data.from(string: "abc"))

		XCTAssertFalse(iterator.isValid())

		iterator.seek(toKey: Data.from(string: "abc999"))

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "abc3"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "abc3"))

		iterator.close()
	}

	func testSwift_Comparator_StringCompare_Ascending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
			options.keyType = .nsString
			options.valueType = .nsString
		})

		let expected = NSMutableArray()

		for i in 0..<10000 {
			let str = NSString(format: "a%d", i)
			expected.add(str)
			try! rocks.setObject(str, forKey: str)
		}

		/* Expected Array: [A0, A1, A10, A100, A1000, A1001, A1019, A102, A1020, ...] */
		expected.sort(using: #selector(NSString.compare(_:)))

		let iterator = rocks.iterator()
		var idx = 0

		iterator.enumerateKeys { (key, stop) -> Void in
			XCTAssertEqual(key as? NSString, expected[idx] as? NSString)
			idx += 1
		}
	}

	func testSwift_Comparator_StringCompare_Descending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareDescending)
			options.keyType = .nsString
			options.valueType = .nsString
		})

		let expected = NSMutableArray()

		for i in 0..<10000 {
			let str = NSString(format: "a%d", i)
			expected.add(str)
			try! rocks.setObject(str, forKey: str)
		}

		/* Expected Array: [A9999, A9998 .. A9990, A999, A9989, ...] */
		expected.sort(using: #selector(NSNumber.compare(_:)))

		let iterator = rocks.iterator()
		var idx = 9999

		iterator.enumerateKeys { (key, stop) -> Void in
			XCTAssertEqual(key as? NSString, expected[idx] as? NSString)
			idx -= 1
		}
	}

	func testSwift_Comparator_Number_Ascending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .numberAscending)
			options.keyEncoder = {
				(number) -> Data in
				var r: UInt = number.uintValue
				return Data(bytes: UnsafePointer<UInt8>(&r), count: MemoryLayout<UInt>.size)
			}
			options.keyDecoder = {
				(data) -> AnyObject in
				if (data == nil) {
					return Optional.none!
				}
				var r: UInt = 0
				data?.copyBytes(to: &UInt8(r), count: MemoryLayout<NSInteger>.size)
				return NSNumber(value: r as UInt)
			}
		})

		var i = 0
		while i < 10000 {
			let r = arc4random_uniform(UINT32_MAX);
			let value = try? rocks.object(forKey: NSNumber(value: r as UInt32))
			if value as? Data == nil {
				try! rocks.setObject(Data.from(string: "value"), forKey: NSNumber(value: r as UInt32))
				i += 1
			}
		}

		var count = 0
		var lastKey: NSNumber = NSNumber(value: 0 as UInt)

		let iterator = rocks.iterator()

		iterator.enumerateKeys { (key, stop) -> Void in
			XCTAssertTrue(lastKey.compare(key as! NSNumber) == .orderedAscending)
			lastKey = key as! NSNumber
			count += 1
		}

		XCTAssertEqual(count, 10000);
	}

	func testSwift_Comparator_Number_Decending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .numberDescending)
			options.keyEncoder = {
				(number) -> Data in
				var r: UInt = number.uintValue
				return Data(bytes: UnsafePointer<UInt8>(&r), count: MemoryLayout<UInt>.size)
			}
			options.keyDecoder = {
				(data) -> AnyObject in
				if (data == nil) {
					return Optional.none!
				}
				var r: UInt = 0
				data?.copyBytes(to: &UInt8(r), count: MemoryLayout<NSInteger>.size)
				return NSNumber(value: r as UInt)
			}
		})

		var i = 0
		while i < 10000 {
			let r = arc4random_uniform(UINT32_MAX);
			let value = try? rocks.object(forKey: NSNumber(value: r as UInt32))
			if value as? Data == nil {
				try! rocks.setObject(Data.from(string: "value"), forKey: NSNumber(value: r as UInt32))
				i += 1
			}
		}

		var count = 0
		var lastKey: NSNumber = NSNumber(value: UINT32_MAX as UInt32)

		let iterator = rocks.iterator()

		iterator.enumerateKeys { (key, stop) -> Void in
			XCTAssertTrue(lastKey.compare(key as! NSNumber) == .orderedDescending)
			lastKey = key as! NSNumber
			count += 1
		}

		XCTAssertEqual(count, 10000);
	}
}
