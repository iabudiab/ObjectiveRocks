//: [Previous](@previous)

/*:
# Prefix Seek
*/

import Foundation
import PlaygroundSupport
import ObjectiveRocks


let url: URL = playgroundURL(forDB: "PrefixSeek")

/*:
`RocksDBIterator` supports iterating inside a key-prefix by providing a `RocksDBPrefixExtractor`. One such extractor is built-in and it extracts a fixed-length prefix for each key:
*/
let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
	options.prefixExtractor = RocksDBPrefixExtractor(type: .fixedLength, length: 4)
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

/*:
Given these contrived keys and values:
*/
try! rocks.setData("A", forKey: "server_host")
try! rocks.setData("B", forKey: "db_host")
try! rocks.setData("C", forKey: "server_port")
try! rocks.setData("D", forKey: "db_port")
try! rocks.setData("E", forKey: "db_user")
try! rocks.setData("F", forKey: "server_alias")

/*:
We could for example enumerate only the `server` keys:
*/
let iterator = rocks.iterator()
iterator.enumerateKeysAndValues(withPrefix: "server") { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}

/*:
> Take a look at the `Column Families` for a more structured way to semantically partition/store your data in RocksDB
*/

//: [Next](@next)
