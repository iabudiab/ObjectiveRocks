//: [Previous](@previous)

/*:
# Rocks Options
*/

import Foundation
import PlaygroundSupport
import ObjectiveRocks

/*:
`RocksDB` features highly flexible configuration settings that may be tuned to run on a variety of production environments. A production ready setup for example could look like this:
*/

let url: URL = playgroundURL(forDB: "DBOptions")

let rocks = RocksDB.database(atPath: url.path) { options in
	options.createIfMissing = true

	options.writeBufferSize = 64 * 1024 * 1024
	options.maxWriteBufferNumber = 7
	options.targetFileSizeBase = UInt64(64 * 1024 * 1024)
	options.numLevels = 7

	options.maxLogFileSize = 50 * 1024 * 1024
	options.keepLogFileNum = 30

	options.tableFacotry = RocksDBTableFactory.blockBasedTableFactory { options in
		options.filterPolicy = RocksDBFilterPolicy.bloomFilterPolicy(withBitsPerKey: 10)
		options.blockCache = RocksDBCache.lruCache(withCapacity: 1024 * 1024 * 1024)
		options.blockSize = 64 * 1024;
	}

	options.comparator = RocksDBComparator.comaparator(with: .bytewiseAscending)

	options.mergeOperator = RocksDBMergeOperator(name: "concat") { (key, existing, new) -> Data in
		guard let existing = existing else {
			return new
		}
		var res = existing
		res.append(new)
		return res
	}
}

guard let rocks = rocks else {
	PlaygroundPage.current.finishExecution()
}

/*:
> Notice the use of the `merge` operation. A `MergeOprator` is required in order to use `merges`. In this case the configured operator simply concatenates the data objects.
*/
try! rocks.setData("Hello", forKey: "Key")
try! rocks.merge("World", forKey: "Key")

let data = try! rocks.data(forKey: "Key")
let string = String(data: data, encoding: .utf8)

/*:
In addition to the DB Options, `RocksDB` allows to define default read/write options for all operations:
*/
rocks.setDefault(
	readOptions: { readOptions in
		readOptions.fillCache = false
	},
	writeOptions: { writeOptions in
		writeOptions.disableWriteAheadLog = false
	}
)

/*:
Nonetheless, each single read or write operation can be tuned via specific read/write options:
*/
try! rocks.setData("Data", forKey: "Another Key") { writeOptions in
	writeOptions.syncWrites = true
	writeOptions.disableWriteAheadLog = true
}

try! rocks.data(forKey: "Another Key") { readOptions in
	readOptions.verifyChecksums = true
	readOptions.fillCache = true
}

//: [Next](@next)
