//
//  RocksDBBasicTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBBasicTests : RocksDBTests {

	func testSwift_DB_Open_ErrorIfExists() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})
		rocks.close()

		let db = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.errorIfExists = true
		})

		XCTAssertNil(db)
	}

	func testSwift_DB_CRUD() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})
		rocks.setDefaultReadOptions({ (readOptions) -> Void in
			readOptions.fillCache = true
			readOptions.verifyChecksums = true
		}, andWriteOptions: { (writeOptions) -> Void in
			writeOptions.syncWrites = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 3")), Data("value 3"));

		try! rocks.deleteDataForKey(Data("key 2"))
		XCTAssertNil(try? rocks.dataForKey(Data("key 2")));

		try! self.rocks.deleteDataForKey(Data("key 2"))
	}

	func testSwift_DB_CRUD_Encoded() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .NSString
			options.valueType = .NSString
		})
		rocks.setDefaultReadOptions({ (readOptions) -> Void in
			readOptions.fillCache = true
			readOptions.verifyChecksums = true
			}, andWriteOptions: { (writeOptions) -> Void in
				writeOptions.syncWrites = true
		})

		try! rocks.setObject("value 1", forKey: "key 1")
		try! rocks.setObject("value 2", forKey: "key 2")
		try! rocks.setObject("value 3", forKey: "key 3")
		XCTAssertEqual(try! rocks.objectForKey("key 1") as? String, "value 1");
		XCTAssertEqual(try! rocks.objectForKey("key 2") as? String, "value 2");
		XCTAssertEqual(try! rocks.objectForKey("key 3") as? String, "value 3");

		try! rocks.deleteObjectForKey("key 2")
		let value = try? rocks.objectForKey("key 2")
		XCTAssertNil(value);

		try! self.rocks.deleteObjectForKey("key 2")
	}
}
