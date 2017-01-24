//
//  RocksDBBasicTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBBasicTests : RocksDBTests {

	func testSwift_DB_Open_ErrorIfExists() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})
		rocks.close()

		let db = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.errorIfExists = true
		})

		XCTAssertNil(db)
	}

	func testSwift_DB_CRUD() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})
		rocks.setDefaultReadOptions({ (readOptions) -> Void in
			readOptions.fillCache = true
			readOptions.verifyChecksums = true
		}, andWriteOptions: { (writeOptions) -> Void in
			writeOptions.syncWrites = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 3")), Data.from(string: "value 3"));

		try! rocks.deleteData(forKey: Data.from(string: "key 2"))
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "key 2")));

		try! self.rocks.deleteData(forKey: Data.from(string: "key 2"))
	}

	func testSwift_DB_CRUD_Encoded() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .nsString
			options.valueType = .nsString
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
		XCTAssertEqual(try! rocks.object(forKey: "key 1") as? String, "value 1");
		XCTAssertEqual(try! rocks.object(forKey: "key 2") as? String, "value 2");
		XCTAssertEqual(try! rocks.object(forKey: "key 3") as? String, "value 3");

		try! rocks.deleteObject(forKey: "key 2")
		let value = try? rocks.object(forKey: "key 2")
		XCTAssertNil(value);

		try! self.rocks.deleteObject(forKey: "key 2")
	}
}
