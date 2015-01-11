//
//  RocksDBComparatorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 12/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBComparatorTests : RocksDBTests {

	func testSwift_Comparator_Native_Bytewise_Ascending() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.BytewiseAscending)
		})

		rocks.setData(Data("abc1"), forKey: Data("abc1"))
		rocks.setData(Data("abc2"), forKey: Data("abc2"))
		rocks.setData(Data("abc3"), forKey: Data("abc3"))

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc1"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc1"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc2"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc2"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc3"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc3"))

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc3"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc3"))

		iterator.seekToKey(Data("abc"))

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc1"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc1"))

		iterator.close()
	}

	func testSwift_Comparator_Native_Bytewise_Descending() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.BytewiseDescending)
		})

		rocks.setData(Data("abc1"), forKey: Data("abc1"))
		rocks.setData(Data("abc2"), forKey: Data("abc2"))
		rocks.setData(Data("abc3"), forKey: Data("abc3"))

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc3"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc3"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc2"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc2"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc1"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc1"))

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc1"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc1"))

		iterator.seekToKey(Data("abc"))

		XCTAssertFalse(iterator.isValid())

		iterator.seekToKey(Data("abc999"))

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as NSData, Data("abc3"))
		XCTAssertEqual(iterator.value() as NSData, Data("abc3"))

		iterator.close()
	}

	func testSwift_Comparator_StringCompare_Ascending() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareAscending)
			options.keyType = .NSString
		})

		let expected = NSMutableArray()

		for i in 0...10000 {
			let str = NSString(format: "a%d", i)
			expected.addObject(str)
			rocks.setObject(str, forKey: str)
		}

		/* Expected Array: [A0, A1, A10, A100, A1000, A1001, A1019, A102, A1020, ...] */
		expected.sortUsingSelector(Selector("compare:"))

		let iterator = rocks.iterator()
		var idx = 0

		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			XCTAssertEqual(key as NSString, expected[idx] as NSString)
			idx++
		}
	}

	func testSwift_Comparator_StringCompare_Descending() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareDescending)
			options.keyType = .NSString
		})

		let expected = NSMutableArray()

		for i in 0...10000 {
			let str = NSString(format: "a%d", i)
			expected.addObject(str)
			rocks.setObject(str, forKey: str)
		}

		/* Expected Array: [A9999, A9998 .. A9990, A999, A9989, ...] */
		expected.sortUsingSelector(Selector("compare:"))

		let iterator = rocks.iterator()
		var idx = 9999

		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			XCTAssertEqual(key as NSString, expected[idx] as NSString)
			idx--
		}
	}

	func testSwift_Comparator_Number_Ascending() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.NumberAscending)
			options.keyEncoder = {
				(number) -> NSData in
				var r: NSInteger = number.unsignedIntegerValue
				return NSData(bytes: &r, length: sizeof(NSInteger))
			}
			options.keyDecoder = {
				(data) -> AnyObject in
				if (data == nil) {
					return Optional.None!
				}
				var r: NSInteger = 0
				data.getBytes(&r, length: sizeof(NSInteger))
				return NSNumber(unsignedInteger: r)
			}
		})

		var i = 0
		while i < 10000 {
			let r = arc4random_uniform(UINT32_MAX);
			if (rocks.objectForKey(NSNumber(unsignedInt: r)) == nil) {
				rocks.setObject(Data("value"), forKey: NSNumber(unsignedInt: r))
				i++
			}
		}

		var count = 0
		var lastKey: NSNumber = NSNumber(unsignedInteger: 0)

		let iterator = rocks.iterator()

		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			XCTAssertTrue(lastKey.compare(key as NSNumber) == .OrderedAscending)
			lastKey = key as NSNumber
			count++
		}

		XCTAssertEqual(count, 10000);
	}

	func testSwift_Comparator_Number_Decending() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.NumberDescending)
			options.keyEncoder = {
				(number) -> NSData in
				var r: NSInteger = number.unsignedIntegerValue
				return NSData(bytes: &r, length: sizeof(NSInteger))
			}
			options.keyDecoder = {
				(data) -> AnyObject in
				if (data == nil) {
					return Optional.None!
				}
				var r: NSInteger = 0
				data.getBytes(&r, length: sizeof(NSInteger))
				return NSNumber(unsignedInteger: r)
			}
		})

		var i = 0
		while i < 10000 {
			let r = arc4random_uniform(UINT32_MAX);
			if (rocks.objectForKey(NSNumber(unsignedInt: r)) == nil) {
				rocks.setObject(Data("value"), forKey: NSNumber(unsignedInt: r))
				i++
			}
		}

		var count = 0
		var lastKey: NSNumber = NSNumber(unsignedInt: UINT32_MAX)

		let iterator = rocks.iterator()

		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			XCTAssertTrue(lastKey.compare(key as NSNumber) == .OrderedDescending)
			lastKey = key as NSNumber
			count++
		}

		XCTAssertEqual(count, 10000);
	}
}
