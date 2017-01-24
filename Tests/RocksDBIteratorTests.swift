//
//  RocksDBIteratorTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBIteratorTests : RocksDBTests {

	func testSwift_DB_Iterator() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.seekToFirst()
		while iterator.isValid() {
			actual.add(Str(iterator.key() as! Data))
			iterator.next()
		}

		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_Seek() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))

		let iterator = rocks.iterator()

		iterator.seekToFirst()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "key 1"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "value 1"))

		iterator.next()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "key 2"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "value 2"))

		iterator.next()

		XCTAssertFalse(iterator.isValid())

		iterator.seekToLast()
		iterator.previous()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "key 1"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "value 1"))

		iterator.seekToFirst()
		iterator.seekToLast()

		XCTAssertTrue(iterator.isValid())
		XCTAssertEqual(iterator.key() as? Data, Data.from(string: "key 2"))
		XCTAssertEqual(iterator.value() as? Data, Data.from(string: "value 2"))

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeys { (key, stop) -> Void in
			actual.add(Str(key as! Data))
		}


		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_Reverse() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeys(inReverse: true, using: { (key, stop) -> Void in
			actual.add(Str(key as! Data))
		})

		let expected = [ "key 3", "key 2", "key 1" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_RangeStart() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! rocks.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeys(in: RocksDBMakeKeyRange(Data.from(string: "key 2"), nil), reverse: false)
		{
			(key, stop) -> Void in
			actual.add(Str(key as! Data))
		}

		let expected = [ "key 2", "key 3", "key 4" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_RangeEnd() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! rocks.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeys(in: RocksDBMakeKeyRange(nil, Data.from(string: "key 4")), reverse: false)
		{
			(key, stop) -> Void in
			actual.add(Str(key as! Data))
		}

		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_RangeStartEnd() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! rocks.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeys(in: RocksDBMakeKeyRange(Data.from(string: "key 2"), Data.from(string: "key 4")), reverse: false)
		{
			(key, stop) -> Void in
			actual.add(Str(key as! Data))
		}

		let expected = [ "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeys_Encoded() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .nsString
			options.valueType = .nsString
		})

		try! rocks.setObject("value 1", forKey: "key 1")
		try! rocks.setObject("value 2", forKey: "key 2")
		try! rocks.setObject("value 3", forKey: "key 3")

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeys { (key, stop) -> Void in
			actual.add(key)
		}

		let expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValues { (key, value, stop) -> Void in
			actual.add(Str(key as! Data))
			actual.add(Str(value as! Data))
		}

		let expected = [ "key 1", "value 1", "key 2", "value 2", "key 3", "value 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_Reverse() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValues(inReverse: true, using: { (key, value, stop) -> Void in
			actual.add(Str(key as! Data))
			actual.add(Str(value as! Data))
		})

		let expected = [ "key 3", "value 3", "key 2", "value 2", "key 1", "value 1" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_RangeStart() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! rocks.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValues(in: RocksDBMakeKeyRange(Data.from(string: "key 2"), nil), reverse: false)
		{
			(key, value, stop) -> Void in
			actual.add(Str(key as! Data))
			actual.add(Str(value as! Data))
		}

		let expected = [ "key 2", "value 2", "key 3", "value 3", "key 4", "value 4" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_RangeEnd() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! rocks.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValues(in: RocksDBMakeKeyRange(nil, Data.from(string: "key 4")), reverse: false)
		{
			(key, value, stop) -> Void in
			actual.add(Str(key as! Data))
			actual.add(Str(value as! Data))
		}

		let expected = [ "key 1", "value 1", "key 2", "value 2", "key 3", "value 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_RangeStartEnd() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! rocks.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValues(in: RocksDBMakeKeyRange(Data.from(string: "key 2"), Data.from(string: "key 4")), reverse: false)
		{
			(key, value, stop) -> Void in
			actual.add(Str(key as! Data))
			actual.add(Str(value as! Data))
		}

		let expected = [ "key 2", "value 2", "key 3", "value 3" ]
		XCTAssertEqual(actual, expected)

		iterator.close()
	}

	func testSwift_DB_Iterator_EnumerateKeysAndValues_Encoded() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .nsString
			options.valueType = .nsString
		})

		try! rocks.setObject("value 1", forKey: "key 1")
		try! rocks.setObject("value 2", forKey: "key 2")
		try! rocks.setObject("value 3", forKey: "key 3")

		let actual = NSMutableArray()
		let iterator = rocks.iterator()

		iterator.enumerateKeysAndValues { (key, value, stop) -> Void in
			actual.add(key)
			actual.add(value)
		}

		let expected = [ "key 1", "value 1", "key 2", "value 2", "key 3", "value 3" ];
		XCTAssertEqual(actual, expected)

		iterator.close()
	}
}

