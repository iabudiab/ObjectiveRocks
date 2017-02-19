/*:
# ObjectiveRocks

ObjectiveRocks is an Objective-C wrapper of Facebook's [RocksDB](https://github.com/facebook/rocksdb) - A Persistent Key-Value Store for Flash and RAM Storage.
****

## Quick Overview

RocksDB is a key-value store, where the keys and values are arbitrarily-sized byte streams. The keys are ordered within the key value store according to a specified comparator function. RocksDB supports atomic reads and writes, snapshots, iteration and features many configuration options.

ObjectiveRocks provides an easy interface to RocksDB and an Objective-C friendly API that abstracts away the underlying C++ implementation, so you don't have to deal with it. While there is no need to learn the details about RocksDB to use this wrapper, a basic understanding of the internals is recommended and would explain the design decisions behind the, somewhat opinionated, API.

If you are interested in the internals of RocksDB, please refer to the [RocksDB Wiki](https://github.com/facebook/rocksdb/wiki).

## Swift

ObjectiveRocks has a pure Objective-C interface and can be used with ease in Swift projects.

## The Minimum You Need to Know

* Keys and values are byte arrays
* All data in the database is logically arranged in sorted order via a given `Comparator`
* RocksDB supports `Column Families`
	* Column Families provide a way to logically partition the database, think collections in MongoDB
	* Can be configured independently
	* Can be added/dropped on the fly
	* Key-value pairs are associated with exactly one `Column Family` in the database.
	* If no column family is specified, the `default` column family is used
* RocksDB provides three basic operations:
	* Get(key)
	* Put(key, value)
	* Delete(key)
* Applications can define a merge operation via a `Merge Operator`
	* A merge is an atomic Read-Modify-Write
* RocksDB features an `Iterator` API to perform `RangeScan` on the database
* RocksDB provides a `Snapshot` API allows an application to create a point-in-time view of a database
* There are many configuration options:
	* `DBOptions`: Controls the behavior of the database
	* `ColumnFamilyOptions`: Controls the behavior of column families
	* `ReadOptions`: apply to single read operations
	* `WriteOptions`: apply to single write operations

## RocksDB Lite

ObjectiveRocks incldues two targets, for iOS and macOS. The iOS target builds the RocksDB Lite version, which doesn't include the complete feature set.

These features are only available in macOS:

* Column Family Metadata
* Write Batch with Index
* Plain and Cuckoo Table Factories
* Vector, HashSkipList, HashLinkList and HashCuckoo Memtable Rep Factories
* Database Backups
* Database Statistics
* Database Properties
* Thread Status

****

# Table of Contents

- [Rocks Basics](Basics)
- [DB Options](DB%20Options)
- [Iteration](Iteration)
- [Prefix Seek](Prefix%20Seek)
- [Column Families](Column%20Families)
- [Write Batches](Write%20Batch)

****

[Next](@next)
*/
