//
//  RockDBTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import Foundation
import XCTest

public func Data(x: String) -> NSData {
	return x.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
}

public func Str(x: NSData) -> NSString {
	return NSString(data: x, encoding: NSUTF8StringEncoding)!
}

public func NumData(x: UInt64) -> NSData {
	var val = x
	return NSData(bytes: &val, length: sizeof(UInt64))
}

public func NumData(x: Float) -> NSData {
	var val = x
	return NSData(bytes: &val, length: sizeof(UInt64))
}

public func Val(data: NSData) -> UInt64 {
	var val: UInt64 = 0
	data.getBytes(&val, length: sizeof(UInt64))
	return val
}

public func Val(data: NSData) -> Float {
	var val: Float = 0
	data.getBytes(&val, length: sizeof(Float))
	return val
}

class RocksDBTests : XCTestCase {

	var path: String!
	var backupPath: String!
	var restorePath: String!
	var checkpointPath1: String!
	var checkpointPath2: String!

	var rocks: RocksDB!

	override func setUp() {
		super.setUp()
		let bundle = NSBundle(forClass: self.dynamicType)
		path = bundle.bundlePath.stringByAppendingPathComponent("ObjectiveRocks")
		backupPath = path.stringByAppendingString("Backup")
		restorePath = path.stringByAppendingString("Restore")
		checkpointPath1 = path.stringByAppendingString("Snapshot1")
		checkpointPath2 = path.stringByAppendingString("Snapshot2")
		
		cleanupDatabase()
	}

	override func tearDown() {
		if (rocks != nil) {
			rocks.close()
		}
		cleanupDatabase()
		super.tearDown()
	}

	func cleanupDatabase() {
		NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
		NSFileManager.defaultManager().removeItemAtPath(backupPath, error: nil)
		NSFileManager.defaultManager().removeItemAtPath(restorePath, error: nil)
		NSFileManager.defaultManager().removeItemAtPath(checkpointPath1, error: nil)
		NSFileManager.defaultManager().removeItemAtPath(checkpointPath2, error: nil)
	}
}