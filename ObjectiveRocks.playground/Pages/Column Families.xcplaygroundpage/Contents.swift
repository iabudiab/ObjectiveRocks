//: [Previous](@previous)

/*:
# Column Families
*/

import Foundation
import PlaygroundSupport
import ObjectiveRocks

/*:
`RocksDB` supports `Column Families`:
* Column Families provide a way to logically partition the database, think collections in MongoDB
* Can be configured independently
* Can be added/dropped on the fly
* Key-value pairs are associated with exactly one `Column Family` in the database
****

To demonsrate the basic concept behind `ColumnFamilies` let's take a look at the following example:
*/

let url: URL = playgroundURL(forDB: "ColumnFamilies")

/*:
`RocksDB` has a `default` Column Family that is always used if not specified otherwise. The `RocksDBColumnFamilyOptions` that you provide
when opening a DB instance are assigned to this `default` Column Family. In this case a `RocksDBComparator` is provided, that sorts String keys in ascending order:
*/
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

/*:
Once you have a `RocksDB` instance you can create and drop column families on the fly. Here we provide a `RocksDBComparator` is provided, that sorts String keys in descending order:

> Notice that you can assign completely different `RocksDBColumnFamilyOptions` for the new Column Family
*/
let columnFamily = rocks.createColumnFamily(withName: "new_column_family") { options in
	options.comparator = RocksDBComparator.comaparator(with: .stringCompareDescending)
}

guard let columnFamily = columnFamily else {
	PlaygroundPage.current.finishExecution()
}

try! columnFamily.setData("1", forKey: "A")
try! columnFamily.setData("3", forKey: "B")
try! columnFamily.setData("5", forKey: "Y")
try! columnFamily.setData("7", forKey: "Z")

/*:
Now if we itereate both the DB and the Column Family, we get the following:
*/
iterate(db: rocks, title: "DB Key/Values")
iterate(db: columnFamily, title: "Column Family Key/Values")

columnFamily.close()
rocks.close()

/*:
If the DB already contains Column Families other than the default, then you need to specify all Column Families that currently exist in the database when opening it, including the default one. You specify the Column Families using a `RocksDBColumnFamiliesDescriptor`:

- important:
The names of `RocksDBComparator` and `RocksDBMergeOperator` are attached to the database and column families when they are created, and are checked on every subsequent database open. If the name changes, the open call will fail. Hence we provide the same key comparators when opening the DB as before.
*/
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

/*:
Accessing the column families in the DB just as easy:
*/
let newColumnFamily = newRocks.columnFamilies().last

guard let newColumnFamily = newColumnFamily else {
	PlaygroundPage.current.finishExecution()
}

/*:
And here is the content of the DB after opening it again:
*/
iterate(db: newRocks, title: "DB Key/Values")
iterate(db: newColumnFamily, title: "Column Family Key/Values")

newRocks.close()

//: [Next](@next)
