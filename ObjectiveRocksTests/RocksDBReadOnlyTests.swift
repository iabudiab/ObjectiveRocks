//
//  RocksDBReadOnlyTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 10/08/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBReadOnlyTests : RocksDBTests {

	func testDB_Open_ReadOnly_NilIfMissing() {
		rocks = RocksDB.databaseForReadOnlyAtPath(path, andDBOptions:nil)
		XCTAssertNil(rocks);
	}

	func testDB_Open_ReadOnly() {
		rocks = RocksDB.databaseAtPath(path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true;
		});
		XCTAssertNotNil(rocks);
		rocks.close()

		rocks = RocksDB.databaseForReadOnlyAtPath(path, andDBOptions:nil)
		XCTAssertNotNil(rocks);
	}

	func testDB_ReadOnly_NotWritable() {
		rocks = RocksDB.databaseAtPath(path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true;
		});
		XCTAssertNotNil(rocks);
		rocks.setData(Data("data"), forKey: Data("key"))
		rocks.close()

		rocks = RocksDB.databaseForReadOnlyAtPath(path, andDBOptions:nil)

		var error: NSError? = nil;
		rocks.dataForKey(Data("key"), error: &error)
		XCTAssertNil(error);

		error = nil;
		rocks.setData(Data("data"), forKey:Data("key"), error:&error);
		XCTAssertNotNil(error);

		error = nil;
		rocks.deleteDataForKey(Data("key"), error:&error);
		XCTAssertNotNil(error);

		error = nil;
		rocks.mergeData(Data("data"), forKey:Data("key"), error:&error);
		XCTAssertNotNil(error);
	}

}
