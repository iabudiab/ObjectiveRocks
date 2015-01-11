//
//  RockDBTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import Foundation
import XCTest

class RocksDBTests : XCTestCase {

	var path: String = ""
	var rocks: RocksDB? = nil

	override func setUp() {
		super.setUp()
		let bundle = NSBundle(forClass: self.dynamicType)
		path = bundle.bundlePath.stringByAppendingPathComponent("ObjectiveRocks")
		cleanupDatabse()
	}

	override func tearDown() {
		super.tearDown()
		cleanupDatabse()
	}

	func cleanupDatabse() {
		NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
	}
}