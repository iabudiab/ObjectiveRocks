//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport
import ObjectiveRocks

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

extension Data: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		var value = value
		self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
	}
}

public func playgroundURL(forDB name: String) -> URL {
	let playgroundShared = PlaygroundSupport.playgroundSharedDataDirectory
	let objectiveRocks = playgroundShared.appendingPathComponent("ObjectiveRocks")
	try? FileManager.default.createDirectory(at: objectiveRocks, withIntermediateDirectories: true, attributes: nil)
	let url = objectiveRocks.appendingPathComponent(name)
	try? FileManager.default.removeItem(atPath: url.path)
	return url
}

public func iterate(db: RocksDB, title: String) {
	print("--------------------------")
	print(title)
	let iterator = db.iterator()
	iterator.enumerateKeysAndValues { (key, value, stop) in
		print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
	}
	iterator.close()
}
