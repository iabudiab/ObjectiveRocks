# Change Log

## [0.7.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.7.0)

Released on 2017.02.19

- RocksDB Version: `4.6.1`: [facebook/rocksdb@8d7926a](https://github.com/facebook/rocksdb/commit/8d7926a766f2ab9bd6e7aa8cba80b5d3ff26c52b)

### Added

- Missing nullability annotations and light-weight generics throughout code base
- New playground content

### Updated

- Project for Xcode 8
- Swift tests for Swift 3
- Playground contents and syntax for Swift 3
- Travis config for iOS 10.2, macOS 10.12
- Deployment targets to macOS 10.10, iOS 9.0

### Removed

- Removed the deprecated `timeoutHint` option
- Removed the deprecated `maxMemCompactionLevel` option

### Breaking Changes

The built-in encoding/decoding of keys and values via the encoding options is completelty removed from this release. The API is completely `NSData`-based now.

- Removed built-it Key/Value `Encoders` and `Decoders`
	- The conversions of custom types to/from `NSData` is the responsibility of the caller
- Removed `EncodingOptions`
- Removed all methods depending on `EncodingOptions` and the built-in key/value `encoding` and all of the their variants:
	- `setObject:forKey:`
	- `deleteObjectForKey:`
	- `objectForKey:`
	- `mergeObject:forKey:`
	- `mergeOperation:forKey:`
- Refactored all `Iterator`, `Key Comparator` and `Merge Operator` methods accordingly
- Removed `NSNumber` Key-Comparators
- Rename method for setting up default read & write options from `setDefaultReadOptions:andWriteOptions:` to `setDefaultReadOptions:writeOptions:`
	- The custom Swift equivalent is `setDefault(readOptions:writeOptions:)`


## [0.6.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.6.0)

Released on 2016.06.12

- RocksDB Version: `4.6.1`: [facebook/rocksdb@8d7926a](https://github.com/facebook/rocksdb/commit/8d7926a766f2ab9bd6e7aa8cba80b5d3ff26c52b)

### Hotfix

- Removed Cocoapods badges from README


## [0.6.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.6.0)

Released on 2016.06.12

- RocksDB Version: `4.6.1`: [facebook/rocksdb@8d7926a](https://github.com/facebook/rocksdb/commit/8d7926a766f2ab9bd6e7aa8cba80b5d3ff26c52b)

### Added

- Support for opening the database in read-only mode
- Support for `Write Batch with Index` and `Write Batch Iterator`
- Support for `Range Compaction` operations
- Nullability annotations
  - Better compatibility with Swift
- New statistics and counters
- Cocoapods Podspec
- Travis integration

### Breaking Changes

- RocksDB initializers were changed to class instead of instance methods
- Removed RocksDB methods without error parameter
  - Better compatibility with Swift's error-handling model
- Refactored all RocksDB methods so that the error parameter is the last
  - Better compatibility with Swift's error-handling model
- Removed `Column Family Metadata` from iOS target
- `RocksDBIteratorKeyRange` is refactored to `RocksDBKeyRange`
  - Key ranges are used not only for iterations but also for compaction jobs
  - Empty-range constant is refactored to open-range, since it represents a range containing all the keys
- ObjectiveRocks builds frameworks now instead of static libraries

## [0.5.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.5.0)

Released on 2016.07.30

- RocksDB Version: `3.11`: [facebook/rocksdb@812c461](https://github.com/facebook/rocksdb/commit/812c461c96869ebcd8e629da8f01e1cea01c00ca)

### Added

- Source code documentation

### Removed

- Removed `+ (instancetype)LRUCacheWithCapacity:numShardsBits:removeScanCountLimit:` RocksDB Cache initializer
  - No longer available since: [facebook/rocksdb@c88ff4c](https://github.com/facebook/rocksdb/commit/c88ff4ca76a6a24632cbdd834f621952a251d7a1)

## [0.4.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.4.0)

Released on 2015.01.17

- RocksDB Version: `3.9`: [facebook/rocksdb@b89d58d](https://github.com/facebook/rocksdb/commit/b89d58dfa3887d561bd772421fb92ef01bd26fc4)

All headers are refactored in this release to provide a pure Objective-C interface for Swift compatibility.

### Added

- Basic support for RocksDB `Env` for configuring priority thread pools
- Support for querying the `Threads Status` 
- Options for `Background Compactions` and `Background Flushes`
- Iterator methods for key-value iteration
- Support for Column Family Metadata
- Swift tests

### Fixed

- Typo in method name in Filter Policy class
- Typo in method name to retrieve column families in RocksDB class

### Changed

- Updated `Thread Status` API
  - Adapted according to the changes introduces in: [facebook/rocksdb@bf287b7](https://github.com/facebook/rocksdb/commit/bf287b76e0e7b5998de49e3ceaa2b34d1f3c13ae)

## [0.3.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.3.0)

Released on 2015.01.05

- RocksDB Version: `3.9`: [facebook/rocksdb@a801c1f](https://github.com/facebook/rocksdb/commit/a801c1fb099167cf48a714483163061062e3dcb7)

This is the first public release of ObjectiveRocks.

### Added

- Database backup and backup-info support
- Database `Checkpoints`
- Support for collecting database statistics, histograms and properties
- Column Family options
- Support for Column Family `memtable rep` factories
- Support for `Block-based`, `Plain-Table` and `Cuckoo-Table` factories
- Support for RocksDB `Cache`
- Support for RocksDB `Filter Policy`

## [0.2.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.2.0)

Released on 2015.02.01

- RocksDB Version: `3.9`: [facebook/rocksdb@a801c1f](https://github.com/facebook/rocksdb/commit/a801c1fb099167cf48a714483163061062e3dcb7)

### Added

- `Column Families` implementation
- Implementation for `Generic Merge Operators`
- Built-In comparator types for `NSString`, `NSNumber`, and RocksDB's own native byte-wise comparator
- Built-In Key-Value encoders and decoders for `NSString` and `NSJSONSerializable` types
- `Write Batch` methods for `merge` operations
- Prefix-based seek iterations
- Tests

## [0.1.0](https://github.com/iabudiab/ObjectiveRocks/releases/tag/0.1.0)

Released on 2015.12.23

- RocksDB Version: `3.9`: [facebook/rocksdb@9cda7cb](https://github.com/facebook/rocksdb/commit/9cda7cb77b0c7208a63579c7e79252f23db92f67)

First release of ObjectiveRocks featuring basic RocksDB functionality:

- [x] Opening and closing RocksDB instances
- [x] Basic DB options
- [x] `Put`, `Get` and `Delete` operations
- [x] `Read` and `Write` options that are specific to single operations
- [x] `Atomic` updates via `Write Batches`
- [x] Key-Value encoders and decoders for converting arbitrary objects to and from `NSData`
- [x] Database iteration support
- [x] Database `Snapshots` - Read-only view over the entire DB
- [x] `Key Comparators` support - For custom key-ordering in the DB
- [x] `Associative Merge Operators` support - Atomic read-modify-write operations
