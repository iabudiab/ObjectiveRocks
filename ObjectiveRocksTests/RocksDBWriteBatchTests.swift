//
//  RocksDBWriteBatchTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBWriteBatchTests : RocksDBTests {

	func testSwift_WriteBatch_Perform() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.performWriteBatch { (batch, options) -> Void in
			batch.setData(Data("value 1"), forKey: Data("key 1"))
			batch.setData(Data("value 2"), forKey: Data("key 2"))
			batch.setData(Data("value 3"), forKey: Data("key 3"))
		}

		XCTAssertEqual(rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Perform_DeleteOps() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

		rocks.performWriteBatch { (batch, options) -> Void in
			batch.deleteDataForKey(Data("key 1"))
			batch.setData(Data("value 2"), forKey: Data("key 2"))
			batch.setData(Data("value 3"), forKey: Data("key 3"))
		}

		XCTAssertNil(rocks.dataForKey(Data("Key 1")))
		XCTAssertEqual(rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Perform_ClearOps() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

		rocks.performWriteBatch { (batch, options) -> Void in
			batch.deleteDataForKey(Data("key 1"))
			batch.setData(Data("value 2"), forKey: Data("key 2"))
			batch.setData(Data("value 3"), forKey: Data("key 3"))
			batch.clear()
			batch.setData(Data("value 4"), forKey: Data("key 4"))
		}

		XCTAssertEqual(rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertNil(rocks.dataForKey(Data("Key 2")))
		XCTAssertNil(rocks.dataForKey(Data("Key 3")))
		XCTAssertEqual(rocks.dataForKey(Data("key 4")), Data("value 4"));
	}

	func testSwift_WriteBatch_Apply() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let batch = rocks.writeBatch()

		batch.setData(Data("value 1"), forKey: Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))

		rocks.applyWriteBatch(batch, error: nil, writeOptions: nil)

		XCTAssertEqual(rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Apply_DeleteOps() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))

		rocks.applyWriteBatch(batch, error: nil, writeOptions: nil)

		XCTAssertNil(rocks.dataForKey(Data("Key 1")))
		XCTAssertEqual(rocks.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(rocks.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(rocks.dataForKey(Data("Key 4")))
	}

	func testSwift_WriteBatch_Apply_MergeOps() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = RocksDBMergeOperator(name: "merge", andBlock: { (key, existing, value) -> AnyObject! in
				var result: NSMutableString = ""
				if let existingValue = existing as? NSData {
					result.setString(Str(existingValue))
				}
				result.appendString(",")
				result.appendString(Str(value as NSData))
				return Data(result)
			})
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))
		batch.mergeData(Data("value 2 new"), forKey: Data("key 2"))

		rocks.applyWriteBatch(batch, error: nil, writeOptions: nil)

		XCTAssertEqual(rocks.dataForKey(Data("key 2")), Data("value 2,value 2 new"));
	}

	func testSwift_WriteBatch_Apply_ClearOps() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let batch = rocks.writeBatch()

		batch.deleteDataForKey(Data("key 1"))
		batch.setData(Data("value 2"), forKey: Data("key 2"))
		batch.setData(Data("value 3"), forKey: Data("key 3"))
		batch.clear()
		batch.setData(Data("value 4"), forKey: Data("key 4"))

		rocks.applyWriteBatch(batch, error: nil, writeOptions: nil)

		XCTAssertEqual(rocks.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertNil(rocks.dataForKey(Data("Key 2")))
		XCTAssertNil(rocks.dataForKey(Data("Key 3")))
		XCTAssertEqual(rocks.dataForKey(Data("key 4")), Data("value 4"));
	}

	func testSwift_WriteBatch_Count() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

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
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .NSString
			options.valueType = .NSString
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))

		rocks.performWriteBatch { (batch, options) -> Void in
			batch.setObject("value 2", forKey: "key 2")
			batch.setObject("value 3", forKey: "key 3")
			batch.deleteObjectForKey("value 1")
		}

		XCTAssertNil(rocks.objectForKey("Key 1"))
		XCTAssertEqual(rocks.objectForKey("key 2") as NSString, "value 2");
		XCTAssertEqual(rocks.objectForKey("key 3") as NSString, "value 3");
	}
}
