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

		try! rocks.setData("abc1", forKey: "abc1")
		try! rocks.setData("abc2", forKey: "abc2")
		try! rocks.setData("abc3", forKey: "abc3")

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc1".data)
		XCTAssertEqual(iterator.value(), "abc1".data)

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc2".data)
		XCTAssertEqual(iterator.value(), "abc2".data)

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc3".data)
		XCTAssertEqual(iterator.value(), "abc3".data)

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc3".data)
		XCTAssertEqual(iterator.value(), "abc3".data)

		iterator.seek(toKey: "abc")

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc1".data)
		XCTAssertEqual(iterator.value(), "abc1".data)

		iterator.close()
	}

	func testSwift_Comparator_Native_Bytewise_Descending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .bytewiseDescending)
		})

		try! rocks.setData("abc1", forKey: "abc1")
		try! rocks.setData("abc2", forKey: "abc2")
		try! rocks.setData("abc3", forKey: "abc3")

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc3".data)
		XCTAssertEqual(iterator.value(), "abc3".data)

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc2".data)
		XCTAssertEqual(iterator.value(), "abc2".data)

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc1".data)
		XCTAssertEqual(iterator.value(), "abc1".data)

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc1".data)
		XCTAssertEqual(iterator.value(), "abc1".data)

		iterator.seek(toKey: "abc")

		XCTAssertFalse(iterator.isValid())

		iterator.seek(toKey: "abc999")

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "abc3".data)
		XCTAssertEqual(iterator.value(), "abc3".data)

		iterator.close()
	}

	func testSwift_Comparator_StringCompare_Ascending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
		})

		var expected = [String]()

		for i in 0..<10000 {
			let str = String(format: "a%d", i)
			expected.append(str)
			try! rocks.setData(str.data, forKey: str.data)
		}

		/* Expected Array: [A0, A1, A10, A100, A1000, A1001, A1019, A102, A1020, ...] */
		expected.sort()

		let iterator = rocks.iterator()
		var idx = 0

		iterator.enumerateKeys { (key, stop) -> Void in
			XCTAssertEqual(String(data: key, encoding: .utf8)!, expected[idx])
			idx += 1
		}
	}

	func testSwift_Comparator_StringCompare_Descending() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareDescending)
		})

		var expected = [String]()

		for i in 0..<10000 {
			let str = String(format: "a%d", i)
			expected.append(str)
			try! rocks.setData(str.data, forKey: str.data)
		}

		/* Expected Array: [A9999, A9998 .. A9990, A999, A9989, ...] */
		expected.sort()

		let iterator = rocks.iterator()
		var idx = 9999

		iterator.enumerateKeys { (key, stop) -> Void in
			XCTAssertEqual(String(data: key, encoding: .utf8), expected[idx])
			idx -= 1
		}
	}
}
