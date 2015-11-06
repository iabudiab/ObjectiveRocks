//
//  RocksDBStatisticsTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBStatisticsTests : RocksDBTests {

	func testSwift_Statistics() {
		let statistics = RocksDBStatistics()

		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.statistics = statistics;
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		XCTAssertNotNil(statistics.description);
	}

	func testSwift_Statistics_Ticker() {
		let statistics = RocksDBStatistics()

		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.statistics = statistics;
		})

		try! rocks.setData(Data("abcd"), forKey: Data("abcd"))

		XCTAssertEqual(statistics.countForTicker(RocksDBTickerType.BytesRead), 0 as UInt64);
		XCTAssertGreaterThan(statistics.countForTicker(RocksDBTickerType.BytesWritten), 0 as UInt64);

		try! rocks.dataForKey(Data("abcd"))

		XCTAssertGreaterThan(statistics.countForTicker(RocksDBTickerType.BytesRead), 0 as UInt64);
	}

	func testSwift_Statistics_Histogram() {
		let statistics = RocksDBStatistics()

		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
			options.statistics = statistics;
		})

		for i in 0...10000 {
			let str = NSString(format: "a%d", i)
			try! rocks.setData(Data(str as String), forKey: Data(str as String))
		}

		try! rocks.dataForKey(Data("a42"))

		let dbGetHistogram = statistics.histogramDataForType(RocksDBHistogramType.DBGet)

		XCTAssertNotNil(dbGetHistogram);
		XCTAssertGreaterThan(dbGetHistogram.median, 0.0);
	}
}

