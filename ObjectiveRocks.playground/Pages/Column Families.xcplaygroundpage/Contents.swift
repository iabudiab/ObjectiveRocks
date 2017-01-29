//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport
import ObjectiveRocks

let url = PlaygroundSupport.playgroundSharedDataDirectory.appendingPathComponent("Rocks")
try! FileManager.default.removeItem(atPath: url.path)

let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
	options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

try! rocks.setData("1", forKey: "A")
try! rocks.setData("2", forKey: "B")
try! rocks.setData("3", forKey: "C")

let columnFamily = rocks.createColumnFamily(withName: "new_column_family") { options in
	options.comparator = RocksDBComparator.comaparator(with: .stringCompareDescending)
}

guard let columnFamily = columnFamily else {
	PlaygroundPage.current.finishExecution()
}

try! columnFamily.setData("1", forKey: "A")
try! columnFamily.setData("2", forKey: "B")
try! columnFamily.setData("3", forKey: "C")

print("--------------------------")
print("DB Key/Values:")
var iterator = rocks.iterator()
iterator.enumerateKeysAndValues { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}
iterator.close()

print("--------------------------")
print("Column Family Key/Values:")
iterator = columnFamily.iterator()
iterator.enumerateKeysAndValues { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}

iterator.close()
columnFamily.close()
rocks.close()

let descriptor = RocksDBColumnFamilyDescriptor()
descriptor.addDefaultColumnFamily { (options) in
	options.comparator = RocksDBComparator.comaparator(with: .stringCompareAscending)
}
descriptor.addColumnFamily(withName: "new_column_family") { (options) in
	options.comparator = RocksDBComparator.comaparator(with: .stringCompareDescending)
}

let newRocks = RocksDB.database(atPath: url.path, columnFamilies: descriptor)

guard let newRocks = newRocks else {
	PlaygroundPage.current.finishExecution()
}

let newColumnFamily = newRocks.columnFamilies().last

guard let newColumnFamily = newColumnFamily else {
	PlaygroundPage.current.finishExecution()
}

print("--------------------------")
print("DB Key/Values:")
iterator = newRocks.iterator()
iterator.enumerateKeysAndValues { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}
iterator.close()

print("--------------------------")
print("Column Family Key/Values:")
iterator = newColumnFamily.iterator()
iterator.enumerateKeysAndValues { (key, value, stop) in
	print("\(String(data: key, encoding: .utf8)!): \(String(data: value, encoding: .utf8)!)")
}

iterator.close()
newRocks.close()
