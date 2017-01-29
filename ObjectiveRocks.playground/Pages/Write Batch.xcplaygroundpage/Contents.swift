//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import ObjectiveRocks

let url = PlaygroundSupport.playgroundSharedDataDirectory.appendingPathComponent("Rocks")
try! FileManager.default.removeItem(atPath: url.path)

let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

try! rocks.setData("D", forKey: "D")
try! rocks.setData("E", forKey: "E")

try! rocks.performWriteBatch { (batch, options) in
	batch.setData("A", forKey: "A")
	batch.setData("B", forKey: "B")
	batch.setData("C", forKey: "C")
	batch.deleteData(forKey: "D")
}

var iterator = rocks.iterator()
iterator.enumerateKeysAndValues { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}
iterator.close()

//: [Next](@next)
