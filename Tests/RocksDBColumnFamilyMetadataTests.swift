//
//  RocksDBColumnFamilyMetadataTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 17/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBColumnFamilyMetadataTests : RocksDBTests {

	func testSwift_ColumnFamilies_Metadata() {
		let descriptor = RocksDBColumnFamilyDescriptor()
		descriptor.addDefaultColumnFamily(options: nil)
		descriptor.addColumnFamily(withName: "new_cf", andOptions: nil)

		rocks = RocksDB.database(atPath: self.path, columnFamilies: descriptor, andDatabaseOptions: { (options) -> Void in
			options.createIfMissing = true
			options.createMissingColumnFamilies = true
		})

		let defaultColumnFamily = rocks.columnFamilies()[0] as! RocksDBColumnFamily
		let newColumnFamily = rocks.columnFamilies()[1] as! RocksDBColumnFamily

		try! defaultColumnFamily.setData(Data.from(string: "df_value1"), forKey: Data.from(string: "df_key1"))
		try! defaultColumnFamily.setData(Data.from(string: "df_value2"), forKey: Data.from(string: "df_key2"))

		try! newColumnFamily.setData(Data.from(string: "cf_value1"), forKey: Data.from(string: "cf_key1"))
		try! newColumnFamily.setData(Data.from(string: "cf_value2"), forKey: Data.from(string: "cf_key2"))

		let defaultMetadata = defaultColumnFamily.columnFamilyMetaData()
		XCTAssertNotNil(defaultMetadata);

		let newColumnFamilyMetadata = newColumnFamily.columnFamilyMetaData()
		XCTAssertNotNil(newColumnFamilyMetadata);
	}
}
