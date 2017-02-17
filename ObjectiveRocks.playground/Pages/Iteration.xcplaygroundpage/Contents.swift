//: [Previous](@previous)

/*:
# Iteration
*/

import Foundation
import PlaygroundSupport
import ObjectiveRocks

let url: URL = playgroundURL(forDB: "Iteration")

let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

try! rocks.setData("A", forKey: "A")
try! rocks.setData("B", forKey: "B")
try! rocks.setData("C", forKey: "C")
try! rocks.setData("D", forKey: "D")
try! rocks.setData("E", forKey: "E")
try! rocks.setData("F", forKey: "F")

/*:
Iteration is provided via the `RocksDBIterator`. You get an instance of a `RocksDBIterator` via the DB object. The `Read Options` closure is optional and will default to those specified in DB instace.
*/

let iterator = rocks.iterator { readOptions in
	// custom read options for this iterator
}

/*:
With an iterator you can either iterate manually:
*/

print("--------------------------")
print("Manual Iteration:")
iterator.seek(toKey: "C")
while iterator.isValid() {
	print(String(data: iterator.value(), encoding: .utf8)!)
	iterator.next()
}

/*:
or use one of the many provided iteration blocks. For example:
*/
print("--------------------------")
print("Enumeration Block:")
iterator.enumerateKeysAndValues { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}

/*:
you can also iterate in reverse or in a given key range.
*/
print("--------------------------")
print("Enumeration in Reverse in a Given Ragne:")
let range = RocksDBKeyRange(start: "E", end: "C")
iterator.enumerateKeysAndValues(in: range, reverse: true) { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}

/*:
> Do not forget to close the iterator when you are done using it:
*/
iterator.close()
rocks.close()

//: [Next](@next)
