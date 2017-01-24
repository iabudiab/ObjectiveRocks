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
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try!  rocks.performWriteBatch { (batch, options) -> Void in
			batch.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
			batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
			batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		}

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 3")), Data.from(string: "value 3"));
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 4")))
	}

	func testSwift_WriteBatch_Perform_DeleteOps() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		try! rocks.performWriteBatch ({ (batch, options) -> Void in
			batch.deleteData(forKey: Data.from(string: "key 1"))
			batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
			batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		})

		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 1")))
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 3")), Data.from(string: "value 3"));
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 4")))
	}

	func testSwift_WriteBatch_Perform_ClearOps() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		try! rocks.performWriteBatch ({ (batch, options) -> Void in
			batch.deleteData(forKey: Data.from(string: "key 1"))
			batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
			batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
			batch.clear()
			batch.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))
		})

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"));
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 2")))
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 3")))
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 4")), Data.from(string: "value 4"));
	}

	func testSwift_WriteBatch_Apply() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let batch = rocks.writeBatch()

		batch.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		try! rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 3")), Data.from(string: "value 3"));
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 4")))
	}

	func testSwift_WriteBatch_Apply_DeleteOps() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		let batch = rocks.writeBatch()

		batch.deleteData(forKey: Data.from(string: "key 1"))
		batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		try! rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 1")))
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"));
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 3")), Data.from(string: "value 3"));
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 4")))
	}

	func testSwift_WriteBatch_Apply_MergeOps() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.mergeOperator = RocksDBMergeOperator(name: "merge", andBlock: { (key, existing, value) -> AnyObject in
				let result: NSMutableString = ""
				if let existingValue = existing as? Data {
					result.setString(Str(existingValue) as String)
				}
				result.append(",")
				result.append(Str(value as! Data) as String)
				return Data(result as String)
			})
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		let batch = rocks.writeBatch()

		batch.deleteData(forKey: Data.from(string: "key 1"))
		batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		batch.mergeData(Data.from(string: "value 2 new"), forKey: Data.from(string: "key 2"))

		try!  rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2,value 2 new"));
	}

	func testSwift_WriteBatch_Apply_ClearOps() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		let batch = rocks.writeBatch()

		batch.deleteData(forKey: Data.from(string: "key 1"))
		batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		batch.clear()
		batch.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 4"))

		try! rocks.applyWriteBatch(batch, writeOptions: nil)

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"));
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 2")))
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "Key 3")))
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 4")), Data.from(string: "value 4"));
	}

	func testSwift_WriteBatch_Count() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		let batch = rocks.writeBatch()

		batch.deleteData(forKey: Data.from(string: "key 1"))

		XCTAssertEqual(batch.count(), 1 as Int32);

		batch.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		batch.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		XCTAssertEqual(batch.count(), 3 as Int32);

		batch.clear()

		XCTAssertEqual(batch.count(), 0 as Int32);

		batch.setData(Data.from(string: "value 4"), forKey: Data.from(string: "key 3"))
		batch.setData(Data.from(string: "value 5"), forKey: Data.from(string: "key 4"))

		XCTAssertEqual(batch.count(), 2 as Int32);

		batch.deleteData(forKey: Data.from(string: "key 4"))

		XCTAssertEqual(batch.count(), 3 as Int32);
	}

	func testSwift_WriteBatch_Encoded() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.keyType = .nsString
			options.valueType = .nsString
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		try! rocks.performWriteBatch ({ (batch, options) -> Void in
			batch.setObject("value 2", forKey: "key 2")
			batch.setObject("value 3", forKey: "key 3")
			batch.deleteObject(forKey: "key 1")
		})

		let value = try? rocks.object(forKey: "key 1")
		XCTAssertNil(value)
		XCTAssertEqual(try! rocks.object(forKey: "key 2") as! NSString, "value 2");
		XCTAssertEqual(try! rocks.object(forKey: "key 3") as! NSString, "value 3");
	}
}
