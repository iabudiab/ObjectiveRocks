//
//  RocksDBCheckpointTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBCheckpointTests : RocksDBTests {

	func testSwift_Checkpoint() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		let checkpoint = RocksDBCheckpoint(database: rocks)

		try! checkpoint.createCheckpointAtPath(checkpointPath1)

		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))

		try! checkpoint.createCheckpointAtPath(checkpointPath2)

		rocks.close()

		rocks = RocksDB.databaseAtPath(self.checkpointPath1, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertNil(try? rocks.dataForKey(Data("key 2")))

		rocks.close()

		rocks = RocksDB.databaseAtPath(self.checkpointPath2, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertEqual(try! rocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertEqual(try! rocks.dataForKey(Data("key 2")), Data("value 2"))
	}
}
