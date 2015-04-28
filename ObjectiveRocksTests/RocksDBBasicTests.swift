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
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})
		rocks.close()

		let db = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.errorIfExists = true
		})

		XCTAssertNil(db)
	}

	func testSwift_DB_CRUD() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})
		rocks.setDefaultReadOptions({ (readOptions) -> Void in
			readOptions.fillCache = true
			readOptions.verifyChecksums = true
		}, andWriteOptions: { (writeOptions) -> Void in
			writeOptions.syncWrites = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		XCTAssertEqual(rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(rocks.dataForKey(Data("key 3")), Data("value 3"));

		rocks.deleteDataForKey(Data("key 2"))
		XCTAssertNil(rocks.dataForKey(Data("key 2")));

		var error: NSError? = nil
		var ok = rocks.deleteDataForKey(Data("key 2"), error:&error);
		XCTAssertTrue(ok);
		XCTAssertNil(error);
	}

	func testSwift_DB_CRUD_Encoded() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
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

		rocks.setObject("value 1", forKey: "key 1")
		rocks.setObject("value 2", forKey: "key 2")
		rocks.setObject("value 3", forKey: "key 3")


		XCTAssertEqual(rocks.objectForKey("key 1") as! NSString, "value 1");
		XCTAssertEqual(rocks.objectForKey("key 2") as! NSString, "value 2");
		XCTAssertEqual(rocks.objectForKey("key 3") as! NSString, "value 3");

		rocks.deleteObjectForKey("key 2")
		XCTAssertNil(rocks.objectForKey("key 2"));

		var error: NSError? = nil
		var ok = rocks.deleteObjectForKey("key 2", error:&error);
		XCTAssertTrue(ok);
		XCTAssertNil(error);
	}
}
