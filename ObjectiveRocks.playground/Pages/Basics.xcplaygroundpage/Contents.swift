//: ObjectiveRocks: an Objective-C wrapper for Facebook's rocksdb

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

try! rocks.setData("World", forKey: "Hello")
try! rocks.setData("Bar", forKey: "Foo")

let data = try! rocks.data(forKey: "Hello")
let string = String(data: data, encoding: .utf8)

try! rocks.deleteData(forKey: "Hello")

//: [Next](@next)
