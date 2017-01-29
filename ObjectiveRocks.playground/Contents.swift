//: Playground - noun: a place where people can play

import Cocoa
import PlaygroundSupport
import ObjectiveRocks

PlaygroundPage.current.needsIndefiniteExecution = true

let url = PlaygroundSupport.playgroundSharedDataDirectory.appendingPathComponent("Rocks")
try FileManager.default.removeItem(atPath: url.path)

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

let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

try rocks.performWriteBatch { batch, writeOptions -> Void in
	batch.setData(-10, forKey: "0001")
	batch.setData(9, forKey: "0011")
	batch.setData(-8, forKey: "0002")
	batch.setData(7, forKey: "0003")
	batch.setData(-6, forKey: "0012")
	batch.setData(5, forKey: "0004")
	batch.setData(-4, forKey: "0005")
	batch.setData(3, forKey: "0006")
	batch.setData(-2, forKey: "0007")
	batch.setData(11, forKey: "0008")
	batch.setData(1, forKey: "0009")
}

rocks.iterator().enumerateKeys(withPrefix: "000") { key, stop -> Void in
	do {
		let data = try rocks.data(forKey: key)
		let value: Int = data.withUnsafeBytes { $0.pointee }
		print(value)

		if value > 10 {
			var shouldStop: ObjCBool = true
			stop.initialize(to: shouldStop)
		}
	} catch {}
}

PlaygroundPage.current.finishExecution()
