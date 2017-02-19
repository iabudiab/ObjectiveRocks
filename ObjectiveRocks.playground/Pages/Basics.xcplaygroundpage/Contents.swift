//: [Previous](@previous)

/*:
# Rocks Basics
*/

import Foundation
import PlaygroundSupport
import ObjectiveRocks

/*:
To open a database you have to specify its location:
*/
let url: URL = playgroundURL(forDB: "Basics")

/*:
`RocksDB` features many configuration settings, that can be specified when opening the database. `ObjectiveRocks` offers a blocks-based initializer for this purpose. The minimum configuration that you'll need is `createIfMissing` in order to create a new database if it doesn't already exist:
*/
let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

/*:
`RocksDB` provides three basic operations, `Put`, `Get`, and `Delete` to store/query data. Keys and values in `RocksDB` are arbitrary byte arrays:
*/
try! rocks.setData("RocksDB".data(using: .utf8)!, forKey: "First Key".data(using: .utf8)!)

/*:
Alternatively, you can define some mappers or extensions for a more friendly usage:

> Checkout the extensions in `Support.swift` file in this playground
*/
try! rocks.setData("World", forKey: "Hello")
try! rocks.setData("Bar", forKey: "Foo")

let data = try! rocks.data(forKey: "Hello")
let string = String(data: data, encoding: .utf8)

try! rocks.deleteData(forKey: "Hello")

//: [Next](@next)
