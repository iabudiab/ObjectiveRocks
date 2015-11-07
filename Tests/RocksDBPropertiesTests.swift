//
//  RocksDBPropertiesTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBPropertiesTests : RocksDBTests {

	func testSwift_Properties() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.maxWriteBufferNumber = 10;
			options.minWriteBufferNumberToMerge = 10;
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		XCTAssertGreaterThan(rocks.valueForIntProperty(.NumEntriesActiveMemtable), 0 as UInt64);
		XCTAssertGreaterThan(rocks.valueForIntProperty(.CurSizeActiveMemTable), 0 as UInt64);
	}

	func testSwift_Properties_ColumnFamily() {

		let descriptor = RocksDBColumnFamilyDescriptor()
		descriptor.addDefaultColumnFamilyWithOptions(nil)
		descriptor.addColumnFamilyWithName("new_cf", andOptions: nil)

		rocks = RocksDB.databaseAtPath(path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		XCTAssertGreaterThanOrEqual(rocks.columnFamilies()[0].valueForIntProperty(.EstimatedNumKeys), 0 as UInt64);
		XCTAssertNotNil(rocks.columnFamilies()[0].valueForProperty(.Stats));
		XCTAssertNotNil(rocks.columnFamilies()[0].valueForProperty(.SsTables));

		XCTAssertGreaterThanOrEqual(rocks.columnFamilies()[1].valueForIntProperty(.EstimatedNumKeys), 0 as UInt64);
		XCTAssertNotNil(rocks.columnFamilies()[1].valueForProperty(.Stats));
		XCTAssertNotNil(rocks.columnFamilies()[1].valueForProperty(.SsTables));
	}
}
