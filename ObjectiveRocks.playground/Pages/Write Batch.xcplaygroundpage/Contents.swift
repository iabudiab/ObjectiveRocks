//: [Previous](@previous)

/*:
# Write Batches
*/

import Foundation
import PlaygroundSupport
import ObjectiveRocks

/*:
You can atomically apply a set of updates to the database using a `WriteBatch`.

Given the following DB and Column Family:
*/

let url: URL = playgroundURL(forDB: "WriteBatch")
let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true
}

let columnFamily = rocks?.createColumnFamily(withName: "CF", andOptions: nil)

guard
	let rocks = rocks,
	let columnFamily = columnFamily
else {
	PlaygroundPage.current.finishExecution()
}

try! rocks.setData("A", forKey: "A")
try! rocks.setData("B", forKey: "B")
try! columnFamily.setData("X", forKey: "X")

/*:
There are two ways to use a `WriteBatch`:

- via the `performWriteBatch` block, e.g.:
*/

try! rocks.performWriteBatch { (batch, options) in
	batch.setData("A New", forKey: "A")
	batch.deleteData(forKey: "B")
	batch.setData("C", forKey: "C")
	batch.setData("X New", forKey: "X", in: columnFamily)
}

/*:
> The Write Batch object operates per default on the Column Family associated with the DB instance, which was used to create it. However, you can also specify the Column Family, in order to achieve an atomic write across multiple Column Families.
> Notice that the whole `WriteBatch` was applied as one atomic operation accross the db and the column family:
*/
iterate(db: rocks, title: "DB Key/Values")
iterate(db: columnFamily, title: "Column Family Key/Values")

/*:
The second way to use `WriteBatch`es is:

- via a `WriteBatch` instance, which may be more flexible for "scattered" logic:
*/
let writeBatch = rocks.writeBatch()
writeBatch.deleteData(forKey: "A")
writeBatch.setData("Y", forKey: "Y", in: columnFamily)
/*
At this point the contents of the DB are still the same, since the `WriteBatch` hasn't been applied yet.

To write the batch you have to apply it:
*/
try! rocks.applyWriteBatch(writeBatch, writeOptions: nil)

iterate(db: rocks, title: "DB Key/Values")
iterate(db: columnFamily, title: "Column Family Key/Values")

//: [Next](@next)
