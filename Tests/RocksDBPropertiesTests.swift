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
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.maxWriteBufferNumber = 10;
			options.minWriteBufferNumberToMerge = 10;
		})

		try! rocks.setData("value 1".data, forKey: "key 1".data)
		try! rocks.setData("value 2".data, forKey: "key 2".data)
		try! rocks.setData("value 3".data, forKey: "key 3".data)

		XCTAssertGreaterThan(rocks.value(for: .numEntriesActiveMemtable), 0 as UInt64);
		XCTAssertGreaterThan(rocks.value(for: .curSizeActiveMemTable), 0 as UInt64);
	}

	func testSwift_Properties_ColumnFamily() {

		let descriptor = RocksDBColumnFamilyDescriptor()
		descriptor.addDefaultColumnFamily(options: nil)
		descriptor.addColumnFamily(withName: "new_cf", andOptions: nil)

		rocks = RocksDB.database(atPath: path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		XCTAssertGreaterThanOrEqual((rocks.columnFamilies()[0]).value(for: .estimatedNumKeys), 0 as UInt64);
		XCTAssertNotNil((rocks.columnFamilies()[0]).value(for: .stats));
		XCTAssertNotNil((rocks.columnFamilies()[0]).value(for: .ssTables));

		XCTAssertGreaterThanOrEqual((rocks.columnFamilies()[1]).value(for: .estimatedNumKeys), 0 as UInt64);
		XCTAssertNotNil((rocks.columnFamilies()[1]).value(for: .stats));
		XCTAssertNotNil((rocks.columnFamilies()[1]).value(for: .ssTables));
	}
}
