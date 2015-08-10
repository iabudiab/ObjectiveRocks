//
//  RocksDBIteratorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBIteratorTests : RocksDBTests {

	func testSwift_DB_Iterator() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		for iterator.seekToFirst(); iterator.isValid(); iterator.next() {
			actual.addObject(Str(iterator.key() as! NSData))
		}

		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_Seek() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as! NSData, Data("key 1"))
		XCTAssertEqual(iterator.value() as! NSData, Data("value 1"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as! NSData, Data("key 2"))
		XCTAssertEqual(iterator.value() as! NSData, Data("value 2"))

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()
		iterator.previous()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as! NSData, Data("key 1"))
		XCTAssertEqual(iterator.value() as! NSData, Data("value 1"))

		iterator.seekToFirst()
		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as! NSData, Data("key 2"))
		XCTAssertEqual(iterator.value() as! NSData, Data("value 2"))

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		}


		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_Reverse() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysInReverse(true, usingBlock: { (key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		})

		let expected = [ "key 3", "key 2", "key 1" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_RangeStart() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysInRange(RocksDBMakeKeyRange(Data("key 2"), nil), reverse: false)
		{
			(key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		}

		let expected = [ "key 2", "key 3", "key 4" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_RangeEnd() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysInRange(RocksDBMakeKeyRange(nil, Data("key 4")), reverse: false)
		{
			(key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		}

		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_RangeStartEnd() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysInRange(RocksDBMakeKeyRange(Data("key 2"), Data("key 4")), reverse: false)
		{
			(key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		}

		let expected = [ "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_Encoded() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .NSString
			options.valueType = .NSString
		})

		rocks.setObject("value 1", forKey: "key 1")
		rocks.setObject("value 2", forKey: "key 2")
		rocks.setObject("value 3", forKey: "key 3")

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			actual.addObject(key)
		}

		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValuesUsingBlock { (key, value, stop) -> Void in
			actual.addObject(Str(key as! NSData))
			actual.addObject(Str(value as! NSData))
		}

		let expected = [ "key 1", "value 1", "key 2", "value 2", "key 3", "value 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_Reverse() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValuesInReverse(true, usingBlock: { (key, value, stop) -> Void in
			actual.addObject(Str(key as! NSData))
			actual.addObject(Str(value as! NSData))
		})

		let expected = [ "key 3", "value 3", "key 2", "value 2", "key 1", "value 1" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_RangeStart() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValuesInRange(RocksDBMakeKeyRange(Data("key 2"), nil), reverse: false)
		{
			(key, value, stop) -> Void in
			actual.addObject(Str(key as! NSData))
			actual.addObject(Str(value as! NSData))
		}

		let expected = [ "key 2", "value 2", "key 3", "value 3", "key 4", "value 4" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_RangeEnd() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValuesInRange(RocksDBMakeKeyRange(nil, Data("key 4")), reverse: false)
		{
			(key, value, stop) -> Void in
			actual.addObject(Str(key as! NSData))
			actual.addObject(Str(value as! NSData))
		}

		let expected = [ "key 1", "value 1", "key 2", "value 2", "key 3", "value 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_RangeStartEnd() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValuesInRange(RocksDBMakeKeyRange(Data("key 2"), Data("key 4")), reverse: false)
		{
			(key, value, stop) -> Void in
			actual.addObject(Str(key as! NSData))
			actual.addObject(Str(value as! NSData))
		}

		let expected = [ "key 2", "value 2", "key 3", "value 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_Encoded() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .NSString
			options.valueType = .NSString
		})

		rocks.setObject("value 1", forKey: "key 1")
		rocks.setObject("value 2", forKey: "key 2")
		rocks.setObject("value 3", forKey: "key 3")

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValuesUsingBlock { (key, value, stop) -> Void in
			actual.addObject(key)
			actual.addObject(value)
		}

		let expected = [ "key 1", "value 1", "key 2", "value 2", "key 3", "value 3" ];
		XCTAssertEqual(actual, expected)

		iterator.close()
	}
}

