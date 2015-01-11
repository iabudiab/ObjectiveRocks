//
//  RocksDBPrefixExtractorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 17/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBPrefixExtractorTests : RocksDBTests {

	func testSwift_PrefixExtractor_FixedLength() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.prefixExtractor = RocksDBPrefixExtractor(type: .FixedLength, length: 3)
			options.keyType = .NSString;
			options.valueType = .NSString;
		})

		rocks.setObject("x", forKey: "100A")
		rocks.setObject("x", forKey: "100B")

		rocks.setObject("x", forKey: "101A")
		rocks.setObject("x", forKey: "101B")

		let iterator = rocks.iterator()
		let keys = NSMutableArray()

		iterator.enumerateKeysWithPrefix("100", usingBlock: { (key, stop) -> Void in
			keys.addObject(key)
		})

		XCTAssertEqual(keys.count, 2);

		var expected = ["100A", "100B"]

		XCTAssertEqual(keys, expected);

		keys.removeAllObjects()

		iterator.enumerateKeysWithPrefix("101", usingBlock: { (key, stop) -> Void in
			keys.addObject(key)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["101A", "101B"]
		XCTAssertEqual(keys, expected);

		iterator.seekToKey("1000")

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSString, "100A")

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSString, "100B")
	}

	func testSwift_PrefixExtractor_FixedLength_CustomComparator() {
		// 1001 < 9910 < 2011 < 3412 ...
		let cmp = RocksDBComparator(name: "cmp") { (key1, key2) -> Int32 in
			var sub1: NSString = key1.substringFromIndex(2) as NSString
			var sub2: NSString = key2.substringFromIndex(2) as NSString

			let res = sub1.compare(sub2)
			switch res {
			case .OrderedAscending:
					return 1
			case .OrderedDescending:
					return -1
			case .OrderedSame:
					return 0
			}
		}

		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = cmp
			options.prefixExtractor = RocksDBPrefixExtractor(type: .FixedLength, length: 2)
			options.keyType = .NSString;
			options.valueType = .NSString;

			options.memtablePrefixBloomBits = 100000000;
			options.memtablePrefixBloomProbes = 6;

			options.tableFacotry = RocksDBTableFactory.blockBasedTableFactoryWithOptions({
				(options) -> Void in
				options.filterPolicy = RocksDBFilterPolicy.bloomFilterPolicyWithBitsPerKey(10, useBlockBasedBuilder: true)
			})
		})

		rocks.setObject("x", forKey: "1010")
		rocks.setObject("x", forKey: "4211")
		rocks.setObject("x", forKey: "1012")
		rocks.setObject("x", forKey: "5313")
		rocks.setObject("x", forKey: "1020")
		rocks.setObject("x", forKey: "4221")
		rocks.setObject("x", forKey: "1022")
		rocks.setObject("x", forKey: "5323")

		let iterator = rocks.iterator()
		let keys = NSMutableArray()

		iterator.enumerateKeysWithPrefix("100", usingBlock: { (key, stop) -> Void in
			keys.addObject(key)
		})

		XCTAssertEqual(keys.count, 4);

		var expected = ["1010", "1012", "1020", "1022"]

		XCTAssertEqual(keys, expected);

		keys.removeAllObjects()

		iterator.enumerateKeysWithPrefix("101", usingBlock: { (key, stop) -> Void in
			keys.addObject(key)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["4211", "4221"]
		XCTAssertEqual(keys, expected);


		keys.removeAllObjects()

		iterator.enumerateKeysWithPrefix("101", usingBlock: { (key, stop) -> Void in
			keys.addObject(key)
		})

		XCTAssertEqual(keys.count, 2);

		expected = ["5313", "5323"]
		XCTAssertEqual(keys, expected);
	}
}
