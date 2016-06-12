//
//  RocksDBWriteBatchTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBWriteBatchTests : RocksDBTests {

	func testSwift_WriteBatch_Perform() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try!  rocks.performWriteBatch { (batch, options) -> Void in
			batch.setData(Data("value 1"), forKey: Data("key 1"))
			batch.setData(Data("value 2"), forKey: Data("key 2"))
			batch.setData(Data("value 3"), forKey: Data("key 3"))
		}

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(try? rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Perform_DeleteOps() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		try! rocks.performWriteBatch ({ (batch, options) -> Void in
			batch.deleteDataForKey(Data("key 1"))
			batch.setData(Data("value 2"), forKey: Data("key 2"))
			batch.setData(Data("value 3"), forKey: Data("key 3"))
		})

		XCTAssertNil(try? rocks.dataForKey(Data("Key 1")))
		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(try? rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Perform_ClearOps() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		try! rocks.performWriteBatch ({ (batch, options) -> Void in
			batch.deleteDataForKey(Data("key 1"))
			batch.setData(Data("value 2"), forKey: Data("key 2"))
			batch.setData(Data("value 3"), forKey: Data("key 3"))
			batch.clear()
			batch.setData(Data("value 4"), forKey: Data("key 4"))
		})

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertNil(try? rocks.dataForKey(Data("Key 2")))
		XCTAssertNil(try? rocks.dataForKey(Data("Key 3")))
		XCTAssertEqual(try! rocks.dataForKey(Data("key 4")), Data("value 4"));
	}

	func testSwift_WriteBatch_Apply() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let batch = rocks.writeBatch()

		batch.setData(Data("value 1"), forKey: Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))

		try! rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(try? rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Apply_DeleteOps() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))

		try! rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertNil(try? rocks.dataForKey(Data("Key 1")))
		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(try! rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(try? rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Apply_MergeOps() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = RocksDBMergeOperator(name: "merge", andBlock: { (key, existing, value) -> AnyObject in
				let result: NSMutableString = ""
				if let existingValue = existing as? NSData {
					result.setString(Str(existingValue) as String)
				}
				result.appendString(",")
				result.appendString(Str(value as! NSData) as String)
				return Data(result as String)
			})
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))
		batch.mergeData(Data("value 2 new"), forKey: Data("key 2"))

		try!  rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2,value 2 new"));
	}

	func testSwift_WriteBatch_Apply_ClearOps() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))
		batch.clear()
		batch.setData(Data("value 4"), forKey: Data("key 4"))

		try! rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertNil(try? rocks.dataForKey(Data("Key 2")))
		XCTAssertNil(try? rocks.dataForKey(Data("Key 3")))
		XCTAssertEqual(try! rocks.dataForKey(Data("key 4")), Data("value 4"));
	}

	func testSwift_WriteBatch_Count() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))

		XCTAssertEqual(batch.count(), 1 as Int32);

		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))

		XCTAssertEqual(batch.count(), 3 as Int32);

		batch.clear()

		XCTAssertEqual(batch.count(), 0 as Int32);

		batch.setData(Data("value 4"), forKey: Data("key 3"))
		batch.setData(Data("value 5"), forKey: Data("key 4"))

		XCTAssertEqual(batch.count(), 2 as Int32);

		batch.deleteDataForKey(Data("key 4"))

		XCTAssertEqual(batch.count(), 3 as Int32);
	}

	func testSwift_WriteBatch_Encoded() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .NSString
			options.valueType = .NSString
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		try! rocks.performWriteBatch ({ (batch, options) -> Void in
			batch.setObject("value 2", forKey: "key 2")
			batch.setObject("value 3", forKey: "key 3")
			batch.deleteObjectForKey("key 1")
		})

		let value = try? rocks.objectForKey("key 1")
		XCTAssertNil(value)
		XCTAssertEqual(try! rocks.objectForKey("key 2") as! NSString, "value 2");
		XCTAssertEqual(try! rocks.objectForKey("key 3") as! NSString, "value 3");
	}
}
