//
//  RocksDBSnapshotTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBSnapshotTests : RocksDBTests {

	func testSwift_Snapshot() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		});

		try! rocks.setData("value 1", forKey: "key 1")
		try! rocks.setData("value 2", forKey: "key 2")
		try! rocks.setData("value 3", forKey: "key 3")

		let snapshot = rocks.snapshot()

		try! rocks.deleteData(forKey: "key 1")
		try! rocks.setData("value 4", forKey: "key 4")

		XCTAssertEqual(try! snapshot.data(forKey: "key 1"), "value 1".data)
		XCTAssertEqual(try! snapshot.data(forKey: "key 2"), "value 2".data)
		XCTAssertEqual(try! snapshot.data(forKey: "key 3"), "value 3".data)
		XCTAssertNil(try? snapshot.data(forKey: "Key 4"))

		snapshot.close()

		XCTAssertNil(try? snapshot.data(forKey: "Key 1"))
		XCTAssertEqual(try! snapshot.data(forKey: "key 4"), "value 4".data)
	}

	func testSwift_Snapshot_Iterator() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData("value 1", forKey: "key 1")
		try! rocks.setData("value 2", forKey: "key 2")
		try! rocks.setData("value 3", forKey: "key 3")

		let snapshot = rocks.snapshot()

		try! rocks.deleteData(forKey: "key 1")
		try! rocks.setData("value 4", forKey: "key 4")

		var actual = [String]()
		var iterator = snapshot.iterator()
		iterator.enumerateKeys { (key, stop) -> Void in
			actual.append(String(data: key, encoding: .utf8)!)
		}

		var expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		snapshot.close()

		actual.removeAll()

		iterator = snapshot.iterator()
		iterator.enumerateKeys { (key, stop) -> Void in
			actual.append(String(data: key, encoding: .utf8)!)
		}

		expected = [ "key 2", "key 3", "key 4" ]
		XCTAssertEqual(actual, expected)
	}

	func testSwift_Snapshot_SequenceNumber() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData("value 1", forKey: "key 1")
		let snapshot1 = rocks.snapshot()

		try! rocks.setData("value 2", forKey: "key 2")
		let snapshot2 = rocks.snapshot()

		try! rocks.setData("value 3", forKey: "key 3")
		let snapshot3 = rocks.snapshot()

		XCTAssertEqual(snapshot1.sequenceNumber(), 1 as UInt64)
		XCTAssertEqual(snapshot2.sequenceNumber(), 2 as UInt64)
		XCTAssertEqual(snapshot3.sequenceNumber(), 3 as UInt64)

		snapshot1.close()
		snapshot2.close()
		snapshot3.close()
	}
}
