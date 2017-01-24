//
//  RocksDBCheckpointTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBCheckpointTests : RocksDBTests {

	func testSwift_Checkpoint() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		let checkpoint = RocksDBCheckpoint(database: rocks)

		try! checkpoint.createCheckpoint(atPath: checkpointPath1)

		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))

		try! checkpoint.createCheckpoint(atPath: checkpointPath2)

		rocks.close()

		rocks = RocksDB.database(atPath: self.checkpointPath1, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"))
		XCTAssertNil(try? rocks.data(forKey: Data.from(string: "key 2")))

		rocks.close()

		rocks = RocksDB.database(atPath: self.checkpointPath2, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"))
		XCTAssertEqual(try! rocks.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"))
	}
}
