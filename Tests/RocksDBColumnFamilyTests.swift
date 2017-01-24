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
		XCTAssertEqual(names[0] as? NSString, "default")
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
		XCTAssertEqual(names[0] as? NSString, "default")
		XCTAssertEqual(names[1] as? NSString, "new_cf")
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
		XCTAssertEqual(names[0] as? NSString, "default")
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
		XCTAssertEqual(names[0] as? NSString, "default")
		XCTAssertEqual(names[1] as? NSString, "new_cf")

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

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

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
		XCTAssertEqual(names[0] as? NSString, "default")
		XCTAssertEqual(names[1] as? NSString, "new_cf")

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

		try! rocks.setData(Data.from(string: "df_value"), forKey: Data.from(string: "df_key1"))
		try! rocks.setData(Data.from(string:"df_value"), forKey: Data.from(string: "df_key2"))

		let columnFamily = rocks.createColumnFamily(withName: "new_cf", andOptions:nil)
		XCTAssertNotNil(columnFamily)
		try! columnFamily?.setData(Data.from(string: "cf_value"), forKey: Data.from(string: "cf_key1"))
		try! columnFamily?.setData(Data.from(string: "cf_value"), forKey: Data.from(string: "cf_key2"))

		columnFamily?.close()
		rocks.close()

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamily(options: nil)
		descriptor.addColumnFamily(withName: "new_cf", andOptions: nil)

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "df_key1")), Data.from(string: "df_value"))
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "df_key2")), Data.from(string: "df_value"))
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "cf_key1")))
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "cf_key2")))

		XCTAssertEqual(try! defaultColumnFamily.data(forKey: Data.from(string: "df_key1")), Data.from(string: "df_value"))
		XCTAssertEqual(try! defaultColumnFamily.data(forKey: Data.from(string: "df_key2")), Data.from(string: "df_value"))

		XCTAssertNil(try? defaultColumnFamily.data(forKey: Data.from(string: "cf_key1")))
		XCTAssertNil(try? defaultColumnFamily.data(forKey: Data.from(string: "cf_key2")))

		XCTAssertEqual(try! newColumnFamily.data(forKey: Data.from(string: "cf_key1")), Data.from(string: "cf_value"))
		XCTAssertEqual(try! newColumnFamily.data(forKey: Data.from(string: "cf_key2")), Data.from(string: "cf_value"))

		XCTAssertNil(try? newColumnFamily.data(forKey: Data.from(string: "df_key1")))
		XCTAssertNil(try? newColumnFamily.data(forKey: Data.from(string: "df_key2")))

		try! newColumnFamily.deleteData(forKey: Data.from(string: "cf_key1"))
		XCTAssertNil(try? newColumnFamily.data(forKey: Data.from(string: "cf_key1")))

		try! newColumnFamily.deleteData(forKey: Data.from(string: "cf_key1"))
		XCTAssertNil(try? newColumnFamily.data(forKey: Data.from(string: "cf_key1")))

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

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		try! newColumnFamily.setData(Data.from(string: "xyz_value"), forKey: Data.from(string: "xyz"))

		let batch = newColumnFamily.writeBatch()

		batch.setData(Data.from(string: "cf_value1"), forKey:Data.from(string: "cf_key1"))
		batch.setData(Data.from(string: "df_value"), forKey:Data.from(string: "df_key"), in:defaultColumnFamily)
		batch.setData(Data.from(string: "cf_value2"), forKey:Data.from(string: "cf_key2"))
		batch.deleteData(forKey: Data.from(string: "xyz"), in:defaultColumnFamily)
		batch.deleteData(forKey: Data.from(string: "xyz"))

		try! rocks.applyWriteBatch(batch, writeOptions:nil)

		XCTAssertEqual(try! defaultColumnFamily.data(forKey: Data.from(string: "df_key")), Data.from(string: "df_value"))
		XCTAssertNil(try? defaultColumnFamily.data(forKey: Data.from(string: "df_key1")))
		XCTAssertNil(try? defaultColumnFamily.data(forKey: Data.from(string: "df_key2")))

		XCTAssertEqual(try! newColumnFamily.data(forKey: Data.from(string: "cf_key1")), Data.from(string: "cf_value1"))
		XCTAssertEqual(try! newColumnFamily.data(forKey: Data.from(string: "cf_key2")), Data.from(string: "cf_value2"))
		XCTAssertNil(try? newColumnFamily.data(forKey: Data.from(string: "df_key")))

		XCTAssertNil(try? defaultColumnFamily.data(forKey: Data.from(string: "xyz")))
		XCTAssertNil(try? newColumnFamily.data(forKey: Data.from(string: "xyz")))

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

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		try! defaultColumnFamily.setData(Data.from(string: "df_value1"), forKey: Data.from(string: "df_key1"))
		try! defaultColumnFamily.setData(Data.from(string: "df_value2"), forKey: Data.from(string: "df_key2"))

		try! newColumnFamily.setData(Data.from(string: "cf_value1"), forKey: Data.from(string: "cf_key1"))
		try! newColumnFamily.setData(Data.from(string: "cf_value2"), forKey: Data.from(string: "cf_key2"))

		let dfIterator = defaultColumnFamily.iterator()

		var actual = [String]()

		dfIterator.seekToFirst()
		while dfIterator.isValid() {
			actual.append((dfIterator.key() as! Data).toString())
			actual.append((dfIterator.value() as! Data).toString())
			dfIterator.next()
		}

		var expected = [ "df_key1", "df_value1", "df_key2", "df_value2" ]
		XCTAssertEqual(actual, expected);

		dfIterator.close()

		let cfIterator = newColumnFamily.iterator()

		actual.removeAllObjects()

		cfIterator.seekToFirst()
		while cfIterator.isValid() {
			actual.append(Data.from(string: cfIterator.key() as! String))
			actual.append(Data.from(string: cfIterator.value() as! String))
			cfIterator.next()
		}

		expected = [ "cf_key1", "cf_value1", "cf_key2", "cf_value2" ]
		XCTAssertEqual(actual, expected)

		cfIterator.close()
	
		defaultColumnFamily.close()
		newColumnFamily.close()
	}
}
