//
//  RockDBTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 11/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import Foundation
import XCTest
import ObjectiveRocks

public func AssertThrows(_ message: String = "Expression did not throw",
                         _ function: String = #function,
                         _ file: StaticString = #file,
                         _ line: UInt = #line,
                         expression: () throws -> Void)
{
	var thrown: NSError? = nil
	do {
		try expression()
	} catch {
		thrown = error as NSError
	}

	let completeMessage = "\(message) in function: \(function)"
	XCTAssertNotNil(thrown, completeMessage, file: file, line: line)
}

extension Data {

	static func from(string: String) -> Data {
		return string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
	}

	func toString() -> NSString {
		return NSString(data: self, encoding: String.Encoding.utf8.rawValue)!
	}

	init<T>(from value: T) {
		let count = MemoryLayout.size(ofValue: value)
		var value = value
		self.init(buffer: UnsafeBufferPointer(start: &value, count: count))
	}

	func to<T>(type: T.Type) -> T {
		return self.withUnsafeBytes { $0.pointee }
	}
}

//public func Val(_ data: Data) -> UInt64 {
//	var val: UInt64 = 0
//	(data as NSData).getBytes(&val, length: MemoryLayout<UInt64>.size)
//	return val
//}
//
//public func Val(_ data: Data) -> Float {
//	var val: Float = 0
//	(data as NSData).getBytes(&val, length: MemoryLayout<Float>.size)
//	return val
//}

class RocksDBTests : XCTestCase {

	var path: String!
	var backupPath: String!
	var restorePath: String!
	var checkpointPath1: String!
	var checkpointPath2: String!

	var rocks: RocksDB!

	override func setUp() {
		super.setUp()
		let bundle = Bundle(for: type(of: self))
		path = (bundle.bundlePath as NSString).appendingPathComponent("ObjectiveRocks")
		backupPath = path + "Backup"
		restorePath = path + "Restore"
		checkpointPath1 = path + "Snapshot1"
		checkpointPath2 = path + "Snapshot2"
		
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
		do {
			try FileManager.default.removeItem(atPath: path)
			try FileManager.default.removeItem(atPath: backupPath)
			try FileManager.default.removeItem(atPath: restorePath)
			try FileManager.default.removeItem(atPath: checkpointPath1)
			try FileManager.default.removeItem(atPath: checkpointPath2)
		} catch {}
	}
}
