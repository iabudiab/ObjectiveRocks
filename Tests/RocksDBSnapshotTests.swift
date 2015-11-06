//
//  RocksDBSnapshotTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBSnapshotTests : RocksDBTests {

	func testSwift_Snapshot() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		});

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let snapshot = rocks.snapshot()

		try! rocks.deleteDataForKey(Data("key 1"))
		try! rocks.setData(Data("value 4"), forKey: Data("key 4"))

		XCTAssertEqual(try! snapshot.dataForKey(Data("key 1")), Data("value 1"));
		XCTAssertEqual(try! snapshot.dataForKey(Data("key 2")), Data("value 2"));
		XCTAssertEqual(try! snapshot.dataForKey(Data("key 3")), Data("value 3"));
		XCTAssertNil(try? snapshot.dataForKey(Data("Key 4")))

		snapshot.close()

		XCTAssertNil(try? snapshot.dataForKey(Data("Key 1")))
		XCTAssertEqual(try! snapshot.dataForKey(Data("key 4")), Data("value 4"));
	}

	func testSwift_Snapshot_Iterator() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let snapshot = rocks.snapshot()

		try! rocks.deleteDataForKey(Data("key 1"))
		try! rocks.setData(Data("value 4"), forKey: Data("key 4"))

		let actual: NSMutableArray = []
		var iterator = snapshot.iterator()
		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		}

		var expected = [ "key 1", "key 2", "key 3" ]
		XCTAssertEqual(actual, expected)

		snapshot.close()

		actual.removeAllObjects()

		iterator = snapshot.iterator()
		iterator.enumerateKeysUsingBlock { (key, stop) -> Void in
			actual.addObject(Str(key as! NSData))
		}

		expected = [ "key 2", "key 3", "key 4" ]
		XCTAssertEqual(actual, expected)
	}

	func testSwift_Snapshot_SequenceNumber() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		let snapshot1 = rocks.snapshot()

		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		let snapshot2 = rocks.snapshot()

		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))
		let snapshot3 = rocks.snapshot()

		XCTAssertEqual(snapshot1.sequenceNumber(), 1 as UInt64)
		XCTAssertEqual(snapshot2.sequenceNumber(), 2 as UInt64)
		XCTAssertEqual(snapshot3.sequenceNumber(), 3 as UInt64)

		snapshot1.close()
		snapshot2.close()
		snapshot3.close()
	}
}
