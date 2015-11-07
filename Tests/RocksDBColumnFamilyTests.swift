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
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabaseAtPath(self.path)

		XCTAssertTrue(names.count == 1);
		XCTAssertEqual(names[0] as? NSString, "default")
	}

	func testSwift_ColumnFamilies_Create() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let columnFamily = rocks.createColumnFamilyWithName("new_cf", andOptions: nil)
		columnFamily.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabaseAtPath(self.path)

		XCTAssertTrue(names.count == 2);
		XCTAssertEqual(names[0] as? NSString, "default")
		XCTAssertEqual(names[1] as? NSString, "new_cf")
	}

	func testSwift_ColumnFamilies_Drop() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let columnFamily = rocks.createColumnFamilyWithName("new_cf", andOptions: nil)
		columnFamily.drop()
		columnFamily.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabaseAtPath(self.path)

		XCTAssertTrue(names.count == 1);
		XCTAssertEqual(names[0] as? NSString, "default")
	}

	func testSwift_ColumnFamilies_Open() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareAscending)
		})

		let columnFamily = rocks.createColumnFamilyWithName("new_cf", andOptions: {
			(options) in
			options.comparator = RocksDBComparator.comaparatorWithType(.BytewiseDescending)
		})

		columnFamily.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabaseAtPath(self.path)

		XCTAssertTrue(names.count == 2)
		XCTAssertEqual(names[0] as? NSString, "default")
		XCTAssertEqual(names[1] as? NSString, "new_cf")

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamilyWithOptions { (options) -> Void in
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareAscending)
		}
		descriptor.addColumnFamilyWithName("new_cf", andOptions: { (options) -> Void in
			options.comparator = RocksDBComparator.comaparatorWithType(.BytewiseDescending)
		})

		rocks = RocksDB.databaseAtPath(self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
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
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareAscending)
		})

		let columnFamily = rocks.createColumnFamilyWithName("new_cf", andOptions: {
			(options) in
			options.comparator = RocksDBComparator.comaparatorWithType(.BytewiseDescending)
		})

		columnFamily.close()
		rocks.close()

		let names = RocksDB.listColumnFamiliesInDatabaseAtPath(self.path)

		XCTAssertTrue(names.count == 2)
		XCTAssertEqual(names[0] as? NSString, "default")
		XCTAssertEqual(names[1] as? NSString, "new_cf")

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamilyWithOptions { (options) -> Void in
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareAscending)
		}
		descriptor.addColumnFamilyWithName("new_cf", andOptions: { (options) -> Void in
			options.comparator = RocksDBComparator.comaparatorWithType(.StringCompareAscending)
		})

		rocks = RocksDB.databaseAtPath(self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertNil(rocks)
	}

	func testSwift_ColumnFamilies_CRUD() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("df_value"), forKey: Data("df_key1"))
		try! rocks.setData(Data("df_value"), forKey: Data("df_key2"))

		let columnFamily = rocks.createColumnFamilyWithName("new_cf", andOptions:nil)

		try! columnFamily.setData(Data("cf_value"), forKey: Data("cf_key1"))
		try! columnFamily.setData(Data("cf_value"), forKey: Data("cf_key2"))


		columnFamily.close()
		rocks.close()

		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamilyWithOptions(nil)
		descriptor.addColumnFamilyWithName("new_cf", andOptions: nil)

		rocks = RocksDB.databaseAtPath(self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		XCTAssertEqual(try! rocks.dataForKey(Data("df_key1")), Data("df_value"))
		XCTAssertEqual(try! rocks.dataForKey(Data("df_key2")), Data("df_value"))
		XCTAssertNil(try? rocks.dataForKey(Data("cf_key1")))
		XCTAssertNil(try? rocks.dataForKey(Data("cf_key2")))

		XCTAssertEqual(try! defaultColumnFamily.dataForKey(Data("df_key1")), Data("df_value"))
		XCTAssertEqual(try! defaultColumnFamily.dataForKey(Data("df_key2")), Data("df_value"))

		XCTAssertNil(try? defaultColumnFamily.dataForKey(Data("cf_key1")))
		XCTAssertNil(try? defaultColumnFamily.dataForKey(Data("cf_key2")))

		XCTAssertEqual(try! newColumnFamily.dataForKey(Data("cf_key1")), Data("cf_value"))
		XCTAssertEqual(try! newColumnFamily.dataForKey(Data("cf_key2")), Data("cf_value"))

		XCTAssertNil(try? newColumnFamily.dataForKey(Data("df_key1")))
		XCTAssertNil(try? newColumnFamily.dataForKey(Data("df_key2")))

		try! newColumnFamily.deleteDataForKey(Data("cf_key1"))
		XCTAssertNil(try? newColumnFamily.dataForKey(Data("cf_key1")))

		try! newColumnFamily.deleteDataForKey(Data("cf_key1"))
		XCTAssertNil(try? newColumnFamily.dataForKey(Data("cf_key1")))

		defaultColumnFamily.close()
		newColumnFamily.close()
	}

	func testSwift_ColumnFamilies_WriteBatch() {
		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamilyWithOptions(nil)
		descriptor.addColumnFamilyWithName("new_cf", andOptions: nil)

		rocks = RocksDB.databaseAtPath(self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		try! newColumnFamily.setData(Data("xyz_value"), forKey: Data("xyz"))

		let batch = newColumnFamily.writeBatch()

		batch.setData(Data("cf_value1"), forKey:Data("cf_key1"))
		batch.setData(Data("df_value"), forKey:Data("df_key"), inColumnFamily:defaultColumnFamily)
		batch.setData(Data("cf_value2"), forKey:Data("cf_key2"))
		batch.deleteDataForKey(Data("xyz"), inColumnFamily:defaultColumnFamily)
		batch.deleteDataForKey(Data("xyz"))

		rocks.applyWriteBatch(batch, withWriteOptions:nil)

		XCTAssertEqual(try! defaultColumnFamily.dataForKey(Data("df_key")), Data("df_value"))
		XCTAssertNil(try? defaultColumnFamily.dataForKey(Data("df_key1")))
		XCTAssertNil(try? defaultColumnFamily.dataForKey(Data("df_key2")))

		XCTAssertEqual(try! newColumnFamily.dataForKey(Data("cf_key1")), Data("cf_value1"))
		XCTAssertEqual(try! newColumnFamily.dataForKey(Data("cf_key2")), Data("cf_value2"))
		XCTAssertNil(try? newColumnFamily.dataForKey(Data("df_key")))

		XCTAssertNil(try? defaultColumnFamily.dataForKey(Data("xyz")))
		XCTAssertNil(try? newColumnFamily.dataForKey(Data("xyz")))

		defaultColumnFamily.close()
		newColumnFamily.close()
	}

	func testSwift_ColumnFamilies_Iterator() {
		let descriptor = RocksDBColumnFamilyDescriptor()

		descriptor.addDefaultColumnFamilyWithOptions(nil)
		descriptor.addColumnFamilyWithName("new_cf", andOptions: nil)

		rocks = RocksDB.databaseAtPath(self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		try! defaultColumnFamily.setData(Data("df_value1"), forKey: Data("df_key1"))
		try! defaultColumnFamily.setData(Data("df_value2"), forKey: Data("df_key2"))

		try! newColumnFamily.setData(Data("cf_value1"), forKey: Data("cf_key1"))
		try! newColumnFamily.setData(Data("cf_value2"), forKey: Data("cf_key2"))

		let dfIterator = defaultColumnFamily.iterator()

		let actual = NSMutableArray()

		for dfIterator.seekToFirst(); dfIterator.isValid(); dfIterator.next() {
			actual.addObject(Str(dfIterator.key() as! NSData))
			actual.addObject(Str(dfIterator.value() as! NSData))
		}

		var expected = [ "df_key1", "df_value1", "df_key2", "df_value2" ]
		XCTAssertEqual(actual, expected);

		dfIterator.close()

		let cfIterator = newColumnFamily.iterator()

		actual.removeAllObjects()

		for cfIterator.seekToFirst(); cfIterator.isValid(); cfIterator.next() {
			actual.addObject(Str(cfIterator.key() as! NSData))
			actual.addObject(Str(cfIterator.value() as! NSData))
		}

		expected = [ "cf_key1", "cf_value1", "cf_key2", "cf_value2" ]
		XCTAssertEqual(actual, expected)

		cfIterator.close()
	
		defaultColumnFamily.close()
		newColumnFamily.close()
	}
}
