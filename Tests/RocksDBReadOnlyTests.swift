//
//  RocksDBReadOnlyTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 10/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBReadOnlyTests : RocksDBTests {

	func testDB_Open_ReadOnly_NilIfMissing() {
		rocks = RocksDB.databaseForReadOnly(atPath: path, andDBOptions:nil)
		XCTAssertNil(rocks);
	}

	func testDB_Open_ReadOnly() {
		rocks = RocksDB.database(atPath: path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true;
		});
		XCTAssertNotNil(rocks);
		rocks.close()

		rocks = RocksDB.databaseForReadOnly(atPath: path, andDBOptions:nil)
		XCTAssertNotNil(rocks);
	}

	func testDB_ReadOnly_NotWritable() {
		rocks = RocksDB.database(atPath: path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true;
		});
		XCTAssertNotNil(rocks);
		try! rocks.setData("data", forKey: "key")
		rocks.close()

		rocks = RocksDB.databaseForReadOnly(atPath: path, andDBOptions:nil)

		try! rocks.data(forKey: "key")

		AssertThrows {
			try self.rocks.setData("data", forKey:"key")
		}

		AssertThrows {
			try self.rocks.deleteData(forKey: "key")
		}

		AssertThrows {
			try self.rocks.merge("data", forKey:"key")
		}
	}

}
