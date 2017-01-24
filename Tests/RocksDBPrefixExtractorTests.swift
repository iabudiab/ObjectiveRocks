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
			options.keyType = .nsString;
			options.valueType = .nsString;
		})

		try! rocks.setObject("x", forKey: "100A")
		try! rocks.setObject("x", forKey: "100B")

		try! rocks.setObject("x", forKey: "101A")
		try! rocks.setObject("x", forKey: "101B")

		let iterator = rocks.iterator()
		let keys = NSMutableArray()

		iterator.enumerateKeys(withPrefix: "100", using: { (key, stop) -> Void in
			keys.add(key)
		})

		XCTAssertEqual(keys.count, 2);

		var expected = ["100A", "100B"]

		XCTAssertEqual(keys, expected);

		keys.removeAllObjects()

		iterator.enumerateKeys(withPrefix: "101", using: { (key, stop) -> Void in
			keys.add(key)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["101A", "101B"]
		XCTAssertEqual(keys, expected);

		iterator.seek(toKey: "1000")

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? NSString, "100A")

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? NSString, "100B")
	}

	func testSwift_PrefixExtractor_FixedLength_CustomComparator() {
		// 1001 < 9910 < 2011 < 3412 ...
		let cmp = RocksDBComparator(name: "cmp") { (key1, key2) -> Int32 in
			let sub1: NSString = (key1 as AnyObject).substring(from: 2) as NSString
			let sub2: NSString = (key2 as AnyObject).substring(from: 2) as NSString

			let res = sub1.compare(sub2 as String)
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
			options.keyType = .nsString;
			options.valueType = .nsString;

			options.memtablePrefixBloomBits = 100000000;
			options.memtablePrefixBloomProbes = 6;

			options.tableFacotry = RocksDBTableFactory.blockBasedTableFactory(options: {
				(options) -> Void in
				options?.filterPolicy = RocksDBFilterPolicy.bloomFilterPolicy(withBitsPerKey: 10, useBlockBasedBuilder: true)
			})
		})

		try! rocks.setObject("x", forKey: "1010")
		try! rocks.setObject("x", forKey: "4211")
		try! rocks.setObject("x", forKey: "1012")
		try! rocks.setObject("x", forKey: "5313")
		try! rocks.setObject("x", forKey: "1020")
		try! rocks.setObject("x", forKey: "4221")
		try! rocks.setObject("x", forKey: "1022")
		try! rocks.setObject("x", forKey: "5323")

		let iterator = rocks.iterator()
		let keys = NSMutableArray()

		iterator.enumerateKeys(withPrefix: "10", using: { (key, stop) -> Void in
			keys.add(key)
		})

		XCTAssertEqual(keys.count, 4);

		var expected = ["1010", "1012", "1020", "1022"]

		XCTAssertEqual(keys, expected);

		keys.removeAllObjects()

		iterator.enumerateKeys(withPrefix: "42", using: { (key, stop) -> Void in
			keys.add(key)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["4211", "4221"]
		XCTAssertEqual(keys, expected);


		keys.removeAllObjects()

		iterator.enumerateKeys(withPrefix: "53", using: { (key, stop) -> Void in
			keys.add(key)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["5313", "5323"]
		XCTAssertEqual(keys, expected);
	}
}
