//
//  RocksDBColumnFamilyTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 17/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBColumnFamilyTests : RocksDBTests {

	func testSwift_ColumnFamilies_List() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabase(atPath: self.path)

		XCTAssertTrue(names.count == 1);
		XCTAssertEqual(names[0], "default")
	}

	func testSwift_ColumnFamilies_Create() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let columnFamily = rocks.createColumnFamily(withName: "new_cf", andOptions: nil)

		XCTAssertNotNil(columnFamily)
		columnFamily?.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabase(atPath: self.path)

		XCTAssertTrue(names.count == 2);
		XCTAssertEqual(names[0], "default")
		XCTAssertEqual(names[1], "new_cf")
	}

	func testSwift_ColumnFamilies_Drop() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let columnFamily = rocks.createColumnFamily(withName: "new_cf", andOptions: nil)
		XCTAssertNotNil(columnFamily)
		columnFamily?.drop()
		columnFamily?.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabase(atPath: self.path)

		XCTAssertTrue(names.count == 1);
		XCTAssertEqual(names[0], "default")
	}

	func testSwift_ColumnFamilies_Open() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
		})

		let columnFamily = rocks.createColumnFamily(withName: "new_cf", andOptions: {
			(options) in
			options.comparator = RocksDBComparator.comaparator(with: .bytewiseDescending)
		})
		XCTAssertNotNil(columnFamily)
		columnFamily?.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabase(atPath: self.path)

		XCTAssertTrue(names.count == 2)
		XCTAssertEqual(names[0], "default")
		XCTAssertEqual(names[1], "new_cf")

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamily { (options) -> Void in
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
		}
		descriptor.addColumnFamily(withName: "new_cf", andOptions: { (options) -> Void in
			options.comparator = RocksDBComparator.comaparator(with: .bytewiseDescending)
		})

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertNotNil(rocks);

		XCTAssertTrue(rocks.columnFamilies().count == 2)

		let defaultColumnFamily = rocks.columnFamilies()[0]
		let newColumnFamily = rocks.columnFamilies()[1]

		XCTAssertNotNil(defaultColumnFamily)
		XCTAssertNotNil(newColumnFamily)

		defaultColumnFamily.close()
		newColumnFamily.close()
	}

	func testSwift_ColumnFamilies_Open_ComparatorMismatch() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
		})

		let columnFamily = rocks.createColumnFamily(withName: "new_cf", andOptions: {
			(options) in
			options.comparator = RocksDBComparator.comaparator(with: .bytewiseDescending)
		})

		XCTAssertNotNil(columnFamily)
		columnFamily?.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabase(atPath: self.path)

		XCTAssertTrue(names.count == 2)
		XCTAssertEqual(names[0], "default")
		XCTAssertEqual(names[1], "new_cf")

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamily { (options) -> Void in
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
		}
		descriptor.addColumnFamily(withName: "new_cf", andOptions: { (options) -> Void in
			options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
		})

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertNil(rocks)
	}

	func testSwift_ColumnFamilies_CRUD() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData("df_value", forKey: "df_key1")
		try! rocks.setData("df_value", forKey: "df_key2")

		let columnFamily = rocks.createColumnFamily(withName: "new_cf", andOptions: nil)
		XCTAssertNotNil(columnFamily)
		try! columnFamily?.setData("cf_value", forKey: "cf_key1")
		try! columnFamily?.setData("cf_value", forKey: "cf_key2")

		columnFamily?.close()
		rocks.close()

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamily(options: nil)
		descriptor.addColumnFamily(withName: "new_cf", andOptions: nil)

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0]
		let newColumnFamily = rocks.columnFamilies()[1]

		XCTAssertEqual(try! rocks.data(forKey: "df_key1"), "df_value".data)
		XCTAssertEqual(try! rocks.data(forKey: "df_key2"), "df_value".data)
		XCTAssertNil(try? rocks.data(forKey: "cf_key1"))
		XCTAssertNil(try? rocks.data(forKey: "cf_key2"))

		XCTAssertEqual(try! defaultColumnFamily.data(forKey: "df_key1"), "df_value".data)
		XCTAssertEqual(try! defaultColumnFamily.data(forKey: "df_key2"), "df_value".data)

		XCTAssertNil(try? defaultColumnFamily.data(forKey: "cf_key1"))
		XCTAssertNil(try? defaultColumnFamily.data(forKey: "cf_key2"))

		XCTAssertEqual(try! newColumnFamily.data(forKey: "cf_key1"), "cf_value".data)
		XCTAssertEqual(try! newColumnFamily.data(forKey: "cf_key2"), "cf_value".data)

		XCTAssertNil(try? newColumnFamily.data(forKey: "df_key1"))
		XCTAssertNil(try? newColumnFamily.data(forKey: "df_key2"))

		try! newColumnFamily.deleteData(forKey: "cf_key1")
		XCTAssertNil(try? newColumnFamily.data(forKey: "cf_key1"))

		try! newColumnFamily.deleteData(forKey: "cf_key1")
		XCTAssertNil(try? newColumnFamily.data(forKey: "cf_key1"))

		defaultColumnFamily.close()
		newColumnFamily.close()
	}

	func testSwift_ColumnFamilies_WriteBatch() {
		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamily(options: nil)
		descriptor.addColumnFamily(withName: "new_cf", andOptions: nil)

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0]
		let newColumnFamily = rocks.columnFamilies()[1]

		try! newColumnFamily.setData("xyz_value", forKey: "xyz")

		let batch = newColumnFamily.writeBatch()

		batch.setData("cf_value1", forKey:"cf_key1")
		batch.setData("df_value", forKey:"df_key", in:defaultColumnFamily)
		batch.setData("cf_value2", forKey:"cf_key2")
		batch.deleteData(forKey: "xyz", in:defaultColumnFamily)
		batch.deleteData(forKey: "xyz")

		try! rocks.applyWriteBatch(batch, writeOptions:nil)

		XCTAssertEqual(try! defaultColumnFamily.data(forKey: "df_key"), "df_value".data)
		XCTAssertNil(try? defaultColumnFamily.data(forKey: "df_key1"))
		XCTAssertNil(try? defaultColumnFamily.data(forKey: "df_key2"))

		XCTAssertEqual(try! newColumnFamily.data(forKey: "cf_key1"), "cf_value1".data)
		XCTAssertEqual(try! newColumnFamily.data(forKey: "cf_key2"), "cf_value2".data)
		XCTAssertNil(try? newColumnFamily.data(forKey: "df_key"))

		XCTAssertNil(try? defaultColumnFamily.data(forKey: "xyz"))
		XCTAssertNil(try? newColumnFamily.data(forKey: "xyz"))

		defaultColumnFamily.close()
		newColumnFamily.close()
	}

	func testSwift_ColumnFamilies_Iterator() {
		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamily(options: nil)
		descriptor.addColumnFamily(withName: "new_cf", andOptions: nil)

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0]
		let newColumnFamily = rocks.columnFamilies()[1]

		try! defaultColumnFamily.setData("df_value1", forKey: "df_key1")
		try! defaultColumnFamily.setData("df_value2", forKey: "df_key2")

		try! newColumnFamily.setData("cf_value1", forKey: "cf_key1")
		try! newColumnFamily.setData("cf_value2", forKey: "cf_key2")

		let dfIterator = defaultColumnFamily.iterator()

		var actual = [String]()

		dfIterator.seekToFirst()
		while dfIterator.isValid() {
			actual.append(String(data: dfIterator.key(), encoding: .utf8)!)
			actual.append(String(data: dfIterator.value(), encoding: .utf8)!)
			dfIterator.next()
		}

		var expected = [ "df_key1", "df_value1", "df_key2", "df_value2" ]
		XCTAssertEqual(actual, expected);

		dfIterator.close()

		let cfIterator = newColumnFamily.iterator()

		actual.removeAll()

		cfIterator.seekToFirst()
		while cfIterator.isValid() {
			actual.append(String(data: cfIterator.key(), encoding: .utf8)!)
			actual.append(String(data: cfIterator.value(), encoding: .utf8)!)
			cfIterator.next()
		}

		expected = [ "cf_key1", "cf_value1", "cf_key2", "cf_value2" ]
		XCTAssertEqual(actual, expected)

		cfIterator.close()
	
		defaultColumnFamily.close()
		newColumnFamily.close()
	}
}
