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

// MARK:- Extension

extension Data: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = value.data(using: .utf8)!
	}

	public init(extendedGraphemeClusterLiteral value: String) {
		self = value.data(using: .utf8)!
	}

	public init(unicodeScalarLiteral value: String) {
		self = value.data(using: .utf8)!
	}
}

extension String {
	var data: Data {
		return self.data(using: .utf8)!
	}
}

// MARK:- Util

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

// MARK:- Base

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
