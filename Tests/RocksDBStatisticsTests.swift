//
//  RocksDBStatisticsTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBStatisticsTests : RocksDBTests {

	func testSwift_Statistics() {
		let statistics = RocksDBStatistics()

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.statistics = statistics;
		})

		try! rocks.setData("value 1", forKey: "key 1")

		XCTAssertNotNil(statistics.description);
	}

	func testSwift_Statistics_Ticker() {
		let statistics = RocksDBStatistics()

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.statistics = statistics;
		})

		try! rocks.setData("abcd", forKey: "abcd")

		XCTAssertEqual(statistics.count(for: RocksDBTicker.bytesRead), UInt64(0));
		XCTAssertGreaterThan(statistics.count(for: RocksDBTicker.bytesWritten), UInt64(0));

		try! rocks.data(forKey: "abcd")

		XCTAssertGreaterThan(statistics.count(for: RocksDBTicker.bytesRead), UInt64(0));
	}

	func testSwift_Statistics_Histogram() {
		let statistics = RocksDBStatistics()

		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.statistics = statistics;
		})

		for i in 0...10000 {
			let str = String(format: "a%d", i)
			try! rocks.setData(str.data, forKey: str.data)
		}

		try! rocks.data(forKey: "a42")

		let dbGetHistogram = statistics.histogramData(forType: RocksDBHistogram.dbGet)

		XCTAssertNotNil(dbGetHistogram);
		XCTAssertGreaterThan(dbGetHistogram.median, 0.0);
	}
}
