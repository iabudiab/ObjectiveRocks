//
//  RocksDBPrefixExtractorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 17/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBPrefixExtractorTests : RocksDBTests {

	func testSwift_PrefixExtractor_FixedLength() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.prefixExtractor = RocksDBPrefixExtractor(type: .fixedLength, length: 3)
		})

		try! rocks.setData("x", forKey: "100A")
		try! rocks.setData("x", forKey: "100B")

		try! rocks.setData("x", forKey: "101A")
		try! rocks.setData("x", forKey: "101B")

		let iterator = rocks.iterator()
		var keys = [String]()

		iterator.enumerateKeys(withPrefix: "100", using: { (key, stop) -> Void in
			keys.append(String(data: key, encoding: .utf8)!)
		})

		XCTAssertEqual(keys.count, 2);

		var expected = ["100A", "100B"]

		XCTAssertEqual(keys, expected);

		keys.removeAll()

		iterator.enumerateKeys(withPrefix: "101", using: { (key, stop) -> Void in
			keys.append(String(data: key, encoding: .utf8)!)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["101A", "101B"]
		XCTAssertEqual(keys, expected);

		iterator.seek(toKey: "1000")

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "100A".data)

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key(), "100B".data)
	}

	func testSwift_PrefixExtractor_FixedLength_CustomComparator() {
		// 1001 < 9910 < 2011 < 3412 ...
		let cmp = RocksDBComparator(name: "cmp") { (key1, key2) -> Int32 in
			let str1 = String(data: key1, encoding: .utf8)!
			let str2 = String(data: key2, encoding: .utf8)!

			let sub1 = str1[str1.index(str1.startIndex, offsetBy: 1)...]
			let sub2 = str2[str2.index(str2.startIndex, offsetBy: 1)...]

			let res = sub1.compare(sub2)
			switch res {
			case .orderedAscending:
					return -1
			case .orderedDescending:
					return 1
			case .orderedSame:
					return 0
			}
		}

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = cmp
			options.prefixExtractor = RocksDBPrefixExtractor(type: .fixedLength, length: 2)

			options.tableFacotry = RocksDBTableFactory.blockBasedTableFactory(options: { (options) -> Void in
				options.filterPolicy = RocksDBFilterPolicy.bloomFilterPolicy(withBitsPerKey: 10, useBlockBasedBuilder: true)
			})
		})

		try! rocks.setData("x", forKey: "1010")
		try! rocks.setData("x", forKey: "4211")
		try! rocks.setData("x", forKey: "1012")
		try! rocks.setData("x", forKey: "5313")
		try! rocks.setData("x", forKey: "1020")
		try! rocks.setData("x", forKey: "4221")
		try! rocks.setData("x", forKey: "1022")
		try! rocks.setData("x", forKey: "5323")

		let iterator = rocks.iterator()
		var keys = [String]()

		iterator.enumerateKeys(withPrefix: "10", using: { (key, stop) -> Void in
			keys.append(String(data: key, encoding: .utf8)!)
		})

		XCTAssertEqual(keys.count, 4);

		var expected = ["1010", "1012", "1020", "1022"]

		XCTAssertEqual(keys, expected);

		keys.removeAll()

		iterator.enumerateKeys(withPrefix: "42", using: { (key, stop) -> Void in
			keys.append(String(data: key, encoding: .utf8)!)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["4211", "4221"]
		XCTAssertEqual(keys, expected);

		keys.removeAll()

		iterator.enumerateKeys(withPrefix: "53", using: { (key, stop) -> Void in
			keys.append(String(data: key, encoding: .utf8)!)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["5313", "5323"]
		XCTAssertEqual(keys, expected);
	}
}
