# ObjectiveRocks

ObjectiveRocks is an Objective-C wrapper of Facebook's [RocksDB](https://github.com/facebook/rocksdb) - A Persistent Key-Value Store for Flash and RAM Storage.

[![Build Status](https://travis-ci.org/iabudiab/ObjectiveRocks.svg?branch=develop)](https://travis-ci.org/iabudiab/ObjectiveRocks)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!-- [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ObjectiveRocks.svg?style=flat)](https://cocoapods.org/pods/ObjectiveRocks)
[![CocoaDocs](https://img.shields.io/cocoapods/metrics/doc-percent/ObjectiveRocks.svg?style=flat)](http://cocoadocs.org/docsets/ObjectiveRocks)
[![Platform](https://img.shields.io/cocoapods/p/ObjectiveRocks.svg?style=flat)](http://cocoadocs.org/docsets/ObjectiveRocks) -->
[![License MIT](https://img.shields.io/badge/license-MIT-4481C7.svg?style=flat)](https://opensource.org/licenses/MIT)

- [Quick Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Open & Close a DB Instance](#open--close-a-db-instance)
- [Basic Operations](#basic-operations)
- [Iteration](#iteration)
- [Column Families](#column-families)
- [Atomic Updates](#atomic-updates)
- [Snapshot](#snapshot)
- [Checkpoint](#checkpoint)
- [Keys Comparator](#keys-comparator)
- [Merge Operator](#merge-operator)
- [Env & Thread Status](#env--thread-status)
- [Backup & Restore](#backup--restore)
- [Statistics](#statistics)
- [Properties](#properties)
- [Configuration](#configuration)

# Quick Overview

RocksDB is a key-value store, where the keys and values are arbitrarily-sized byte streams. The keys are ordered within the key value store according to a specified comparator function. RocksDB supports atomic reads and writes, snapshots, iteration and features many configuration options.

ObjectiveRocks provides an easy interface to RocksDB and an Objective-C friendly API that abstracts away the underlying C++ implementation, so you don't have to deal with it. While there is no need to learn the details about RocksDB to use this wrapper, a basic understanding of the internals is recommended and would explain the design decisions behind the, somewhat opinionated, API. 

If you are interested in the internals of RocksDB, please refer to the [RocksDB Wiki](https://github.com/facebook/rocksdb/wiki).

## Swift

ObjectiveRocks has a pure Objective-C interface and can be used in Swift projects. Additionally, all ObjectiveRocks tests are also ported to Swift. You can check the `Tests` targets and source code which also contain bridging headers for OSX and iOS ObjectiveRocks implementations.

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
	* DBOptions: Controls the behavior of the database
	* ColumnFamilyOptions: Controls the behavior of column families
	* ReadOptions: apply to single read operations
	* WriteOptions: apply to single write operations

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

# Installation

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

If you don't have Carthage yet, you can install it with Homebrew using the following command:

```bash
$ brew update
$ brew install carthage
```

To add `ObjectiveRocks` as a dependency into your project using Carthage just add the following line in your `Cartfile`:

```
github "iabudiab/ObjectiveRocks"
```

Then run the following command to build the framework and drag the built `ObjectiveRocks.framework` into your Xcode project.

```bash
$ carthage update
```

## Manually

1- Add `ObjectiveRocks` as git submodule

```bash
$ git submodule add https://github.com/iabudiab/ObjectiveRocks.git
```

2- Open the `ObjectiveRocks` folder and drag'n'drop the `ObjectiveRocks.xcodeproj` into the Project Navigator in Xcode to add it as a sub-project.

3- In the General panel of your target add `ObjectiveRocks.framework` under the `Embedded Binaries` 

> Notice that ObjectiveRocks depends on RocksDB and includes it as a Git submodule.

# Usage

> The README will use the `NSString` notation in place of `NSData` keys and values for brevity!


## Open & close a DB instance

To open a database you have to specify its location:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db"];
...
[db close];
```

`RocksDB` features many configuration settings, that can be specified when opening the database. `ObjectiveRocks` offers a blocks-based initializer for this purpose. The minimum configuration that you'll need is `createIfMissing` in order to create a new database if it doesn't already exist:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
}];
```

The [configuration guide](#configuration), lists all currently available options along with their description.

A more production ready setup could look like this:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;

	options.maxOpenFiles = 50000;

	options.tableFacotry = [RocksDBTableFactory blockBasedTableFactoryWithOptions:^(RocksDBBlockBasedTableOptions *options) {
		options.filterPolicy = [RocksDBFilterPolicy bloomFilterPolicyWithBitsPerKey:10];
		options.blockCache = [RocksDBCache LRUCacheWithCapacity:1024 * 1024 * 1024];
		options.blockSize = 64 * 1024;
	}];

	options.writeBufferSize = 64 * 1024 * 1024;
	options.maxWriteBufferNumber = 7;
	options.targetFileSizeBase = 64 * 1024 * 1024;
	options.numLevels = 7;

	options.maxLogFileSize = 50 * 1024 * 1024;
	options.keepLogFileNum = 30;
}];
```

## Basic Operations

The database provides three basic operations, `Put`, `Get`, and `Delete` to store/query data. Keys and values in RocksDB are arbitrary byte arrays:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
}];

NSData *data = [@"World" dataUsingEncoding:NSUTF8StringEncoding]
NSData *key = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding]

[db storeData:data forKey:key];
NSData *get = [db getDataForKey:key];
[db deleteDataForKey:key];
```

### Read & Write Errors

Database operations can be passed a `NSError` reference to check for any errors that have occurred:

```objective-c
NSError *error = nil;

[db setObject:object forKey:key error:&error];
NSMutableDictionary *dictionary = [db dataForKey:@"Hello" error:&error];
[db deleteDataForKey:@"Hello" error:&error];
```

### Read & Write Options

Each single read or write operation can be tuned via specific options:

```objective-c
[db setObject:anObject forKey:aKey writeOptions:^(RocksDBWriteOptions *writeOptions) {
	writeOptions.syncWrites = YES;
	writeOptions.disableWriteAheadLog = YES;
	writeOptions.timeoutHint = 5;
	writeOptions.ignoreMissingColumnFamilies = NO;
}];

[db dataForKey:aKey readOptions:^(RocksDBReadOptions *readOptions) {
	readOptions.verifyChecksums = YES;
	readOptions.fillCache = NO;
}];
```

Default options can also be set on a `RocksDB` or `RocksDBColumnFamily` instance:

```objective-c
[db setDefaultReadOptions:^(RocksDBReadOptions *readOptions) {
	readOptions.fillCache = YES;
	readOptions.verifyChecksums = YES;
} andWriteOptions:^(RocksDBWriteOptions *writeOptions) {
	writeOptions.syncWrites = YES;
	writeOptions.timeoutHint = 5;
}];
```

You can read about the read and write options in the [configuration guide](#configuration)

## Iteration

Iteration is provided via the `RocksDBIterator` class.

You can either iterate manually:

```objective-c
RocksDB *db = ...;
RocksDBColumnFamily *stuffColumnFamily = .../

RocksDBIterator *iterator = [db iterator];
RocksDBIterator *cfIterator = [stuffColumnFamily iterator];

// Alternatively, you can get an iterator with specific read options
iterator = [db iteratorWithReadOptions:^(RocksDBReadOptions *readOptions) {
	// Read options here
}];

for ([iterator seekToKey:@"start"]; [iterator isValid]; [iterator next]) {
	NSLog(@"%@: %@", [iterator key], [iterator value]);
	// Iterates all keys starting from key "start" 
}
```

or use one of the provided enumeration-blocks:

```objective-c
[db setData:@"Value 1" forKey:@"A"];
[db setData:@"Value 2" forKey:@"B"];
[db setData:@"Value 3" forKey:@"C"];
[db setData:@"Value 3" forKey:@"D"];

RocksDBIterator *iterator = [db iterator];

/* Keys Enumeration */
[db enumerateKeysUsingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@", key);
	// A, B, C, D
}];

// reverse enumeration
[db enumerateKeysInReverse:YES usingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@", key);
	// D, C, B, A
}];

// Enumeration in a given key-range [start, end)
RocksDBIteratorKeyRange range = RocksDBMakeKeyRange(@"A", @"C");

[db enumerateKeysInRange:range reverse:NO usingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@", key, [db dataForKey:key]);
	// B, C
}];

/* Key-Value Enumeration */
[db enumerateKeysAndValuesUsingBlock:^(NSData *key, NSData *value BOOL *stop) {
	NSLog(@"%@:%@", key, value);
	// A:1, B:2, C:3, D:4
}];

[db enumerateKeysAndValuesInReverse:YES usingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@: %@", key, [db dataForKey:key]);
	// D:4, C:3, B:2, A:1
}];

// Enumeration in a given key-range [start, end)
RocksDBIteratorKeyRange range = RocksDBMakeKeyRange(@"A", @"C");

[db enumerateKeysAndValuesInRange:range reverse:YES usingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@:%@", key, [db dataForKey:key]);
	// B:2, C:3
}];
```

## Prefix-Seek Iteration

`RocksDBIterator` supports iterating inside a key-prefix by providing a `RocksDBPrefixExtractor`. One such extractor is built-in and it extracts a fixed-length prefix for each key:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
	options.prefixExtractor = [RocksDBPrefixExtractor prefixExtractorWithType:RocksDBPrefixFixedLength length:2];
}];

[db setData:@"a" forKey:@"10.1"];
[db setData:@"b" forKey:@"10.2"];
[db setData:@"b" forKey:@"10.3"];
[db setData:@"c" forKey:@"11.1"];
[db setData:@"d" forKey:@"11.2"];
[db setData:@"d" forKey:@"11.3"];

RocksDBIterator *iterator = [db iterator];

// Enumeration starts with the key that is Greater-Than-Or-Equal to a key
// with the given "prefix" parameter
[iterator enumerateKeysWithPrefix:@"10" usingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@", key);
	// 10.1, 10.2, 10.3
}];

// .. so in this case the enumeration starts at key "10.2", even if "10.1" 
// has the same prefix
[iterator enumerateKeysWithPrefix:@"10.2" usingBlock:^(NSData *key, BOOL *stop) {
	NSLog(@"%@", key);
	// 10.2, 10.3
}];
```

You can also define your own Prefix Extractor:

```objective-c
RocksDBPrefixExtractor *extractor = [[RocksDBPrefixExtractor alloc] initWithName:@"custom_prefix"
	transformBlock:^id (NSData *key) {
		// Apply your key transformation to extract the prefix part
		id prefix = extractPrefixFromKey(key);
		return prefix;
	}
	prefixCandidateBlock:^BOOL (NSData *key) {
		// You can filter out keys that are not viable candidates for
		// your custom prefix format, e.g. key length is smaller than
		// the target prefix length
		BOOL isCandidate = canExtractPrefixFromKey(key);
		return isCandidate;
	}
	validPrefixBlock:^BOOL (NSData *prefix) {
		// After a prefix is extracted you can perform extra
		// checks here to verify that the prefix is valid
		BOOL isValid = isExtractedPrefixValid(prefix);
		return isValid;
	}
];
```

## Column Families

Once you have a `RocksDB` instance you can create and drop column families on the fly:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:...];

RocksDBColumnFamily *columnFamily = [db createColumnFamilyWithName:@"new_column_family" andOptions:^(RocksDBColumnFamilyOptions *options) {
	// Options for the new column family
};
// Do stuff with columnFamily and close it when you're done
[columnFamily close];

// To drop it
[columnFamily drop];
```

> Notice that the `RocksDBColumnFamily` is a subclass of `RocksDB`

If the database already contains Column Families other than the default, then you need to specify all Column Families that currently exist in the database when opening it, including the default one. You specify the Column Families using a `RocksDBColumnFamiliesDescriptor` object:

```objective-c
RocksDBColumnFamilyDescriptor *descriptor = [RocksDBColumnFamilyDescriptor new];

[descriptor addColumnFamilyWithName:@"default" andOptions:^(RocksDBColumnFamilyOptions *options) {
	// Options for the default column family
}];
[descriptor addColumnFamilyWithName:@"stuff_column_family" andOptions:^(RocksDBColumnFamilyOptions *options) {
	// Options for the stuff_column_family
}];

RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" columnFamilies:descriptor andDatabaseOptions:^(RocksDBDatabaseOptions *options) {
	// Database options here
}];

NSArray *columnFamilies = db.columnFamilies;
RocksDBColumnFamily *defaultColumnFamily = columnFamilies[0];
RocksDBColumnFamily *stuffColumnFamily = columnFamilies[1];
// At this point you can either use the db instance or 
// the defaultColumnFamily instance to access the default column family
```

## Atomic Updates

You can atomically apply a set of updates to the database using a `WriteBatch`. There are two ways to use a `WriteBatch`:

* An inline block-based approach:

```objective-c
[db setData:@"Value 1" forKey:@"Key 1"];

[db performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *writeOptions) {
	[batch setData:@"Value 2" forKey:@"Key 2"];
	[batch setData:@"Value 3" forKey:@"Key 3"];
	[batch deleteDataForKey:@"Key 1"];
}];
```

* Via a `WriteBatch` instance, which may be more flexible for "scattered" logic:

```objective-c
[db setData:@"Value 1" forKey:@"Key 1"];

RocksDBWriteBatch *batch = [db writeBatch];
[batch setData:@"Value 2" forKey:@"Key 2"];
[batch setData:@"Value 3" forKey:@"Key 3"];
[batch deleteDataForKey:@"Key 1"];
...
[db applyWriteBatch:batch withWriteOptions:^(RocksDBWriteOptions *writeOptions) {
	// Write options here
}];
```

The Write Batch object operates per default on the Column Family associated with the DB instance, which was used to create it. However, you can also specify the Column Family, in order to achieve an atomic write across multiple Column Families. In this case it doesn't matter on which instance you apply the batch:

```objective-c
RocksDB *db = ...;
RocksDBColumnFamily *stuffColumnFamily = .../

// Write Batch for default column family
RocksDBWriteBatch *batch = [db writeBatch];

// Write Batch for stuffColumnFamily
RocksDBWriteBatch *cfBatch = [stuffColumnFamily writeBatch];

[batch setData:@"Value 1" forKey:@"Key 1"];
[batch setData:@"Value 2" forKey:@"Key 2" inColumnFamily:stuffColumnFamily];

// You can apply the Write Batch object either on the DB instance
// or the stuffColumnFamily instance.
// The following two calls have the same effect:
/**
	[db applyWriteBatch:batch withWriteOptions:^(RocksDBWriteOptions *writeOptions) {
		// Write options here
	}];
	[stuffColumnFamily applyWriteBatch:batch withWriteOptions:^(RocksDBWriteOptions *writeOptions) {
		// Write options here
	}];
*/
```

## Snapshot

A Snapshot provides consistent read-only view over the state of the key-value store. Do not forget to close the snapshot when it's no longer needed:

```objective-c
[db setData:@"Value 1" forKey:@"A"];

RocksDBSnapshot *snapshot = [db snapshot];
// Alternatively, you can get a snapshot with specific read options
snapshot = [db snapshotWithReadOptions:^(RocksDBReadOptions *readOptions) {
	// Read options here
}];

[db deleteDataForKey:@"A"];
[db setData:@"Value 2" forKey:@"B"];

NSString *value1 = [snapshot dataForKey:@"A"];
// value1 == @"Value 1"
NSString *value2 = [snapshot dataForKey:@"B"];
// value2 == nil
...
[snapshot close];
```

## Checkpoint

A checkpoint is an openable Snapshot of a database at a point in time:

```objective-c
[db setData:@"Value 1" forKey:@"A"];
[db setData:@"Value 2" forKey:@"B"];

RocksDBCheckpoint *checkpoint = [[RocksDBCheckpoint alloc] initWithDatabase:db];
NSError *error = nil;
[checkpoint createCheckpointAtPath:@"path/to/checkpoint" error:&error];

RocksDB *db2 = [RocksDB databaseAtPath:@"path/to/checkpoint"];
...
[db close];
[db2 close];
```

## Keys Comparator

The keys are ordered within the key-value store according to a specified comparator function. The default ordering function for keys orders the bytes lexicographically.

This behavior can be changed by supplying a custom Comparator when opening a database using the `RocksDBComparator`.

Say you have `NSString` keys and you want them to be ordered using a case-insensitive, localized, comparison:

```objective-c
RocksDBComparator *localizedKeys = [[RocksDBComparator alloc] initWithName:@"LocalizedKeys" andBlock:^int (NSData *key1, NSData *key2) {
	return [key1 localizedCaseInsensitiveCompare:key2];
];
	
RocksDB *db = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
	options.comparator = localizedKeys;
}];
```

> The comparator's name is attached to the database when it is created, and is checked on every subsequent database open. If the name changes, the `open` call will fail. Therefore, change the name if new key format and comparison function are incompatible with existing database, and it is ok to discard the contents of the existing database.

## Built-In Comparators

ObjectiveRocks features some built-in comparators, which can be used like this:

```objective-c
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.comparator = [RocksDBComparator comaparatorWithType:RocksDBComparatorNumberAscending];
}];
```

* `RocksDBComparatorBytewiseAscending:` orders the keys lexicographically in ascending order. 
	* This is the default behavior if none is specified.
* `RocksDBComparatorBytewiseDescending` orders the keys lexicographically ins descending order.
* `RocksDBComparatorStringCompareAscending` orders `NSString` keys in ascending order via the `compare` selector.
	* This comparator assumes `NSString` keys and does convert the associated `NSData` via `initWithData:encoding:` using UTF-8
* `RocksDBComparatorStringCompareDescending` orders `NSString` keys in descending order via the `compare` selector.
	* This comparator assumes `NSString` keys and does convert the associated `NSData` via `initWithData:encoding:` using UTF-8

## Merge Operator

A Merge operators is an atomic Read-Modify-Write operation in RocksDB. For a detailed description visit the [Merge Operator](https://github.com/facebook/rocksdb/wiki/Merge-Operator) wiki page in the RocksDB project.

> Analogous to the `comparator` a database created using one `merge operator` cannot be opened using another.

### Associative Merge Operator

You can use this Merge Operator when you have associative data:

* Your merge operands are formatted the same as your Put values, AND
* It is okay to combine multiple operands into one (as long as they are in the same order)

For example we can use a merge operator to append entries to an existing array, instead of reading it completely, updating it and writing it back:

```objective-c
RocksDBMergeOperator *arrayAppend = [RocksDBMergeOperator operatorWithName:@"ArrayAppend" andBlock:^id (NSData *key, NSData *existingValue, NSData *mergeValue) {
	if (existingValue == nil) {
		return mergeValue;
	} else {
		[existingValue addObjectsFromArray:mergeValue];
		return existingValue;
	}
}];

RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.mergeOperator = arrayAppend;
}];

NSMutableArray *letters = [NSMutableArray arrayWithObjects:@"A", @"B", nil];

[db setData:letters forKey:@"Key"];
[db mergeData:@[@"C", @"D"] forKey:@"Key"];
[db mergeData:@[@"E"] forKey:@"Key"];

NSMutableArray *merged = [db dataForKey:@"Key"];
// merged = @[@"A", @"B", @"C", @"D", @"E"];
```

### Generic Merge Operator

If either of the two associativity constraints do not hold, then use the Generic Merge Operator.

The Generic Merge Operator has two methods, PartialMerge, FullMerge:

* PartialMerge: used to combine two-merge operands (if possible). If the client-specified operator can logically handle "combining" two merge-operands into a single operand, the semantics for doing so should be provided in this method, which should then return a non-nil object. If `nil` is returned, then it means that the two merge-operands couldn't be combined into one.

* FullMerge: this function is given an *existingValue* and a list of operands that have been stacked. The client-specified MergeOperator should then apply the operands one-by-one and return the resulting object. If `nil` is returned, then this indicates a failure, i.e. corrupted data, errors ...etc.

ObjectiveRocks has a new `mergeOperation` method for use with a generic Merge Operator. This contrived example shows how a generic merge operator can be used with client-defined merge operations:

```objective-c
RocksDBMergeOperator *mergeOp = [RocksDBMergeOperator operatorWithName:@"operator"
	partialMergeBlock:^id(NSData *key, NSData *leftOperand, NSData *rightOperand) {
		NSString *left = [leftOperand componentsSeparatedByString:@":"][0];
		NSString *right = [rightOperand componentsSeparatedByString:@":"][0];
		if ([left isEqualToString:right]) {
			return rightOperand;
		}
		return nil;
	} fullMergeBlock:^id(id key, id *existing, NSArray *operands) {
		for (NSString *operand in operands) {
			NSArray *components = [operand componentsSeparatedByString:@":"];
			NSString *action = components[1];
			if	([action isEqualToString:@"DELETE"]) {
				[existing removeObjectForKey:components[0]];
			} else {
				existing[comp[0]] = components[2];
			}
		}
		return existing;
	}
];
	
RocksDB *db = [RocksDB databaseAtPath:_path andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
	options.mergeOperator = mergeOp;
}];

NSDictionary *object = @{@"Key 1" : @"Value 1",
						 @"Key 2" : @"Value 2",
						 @"Key 3" : @"Value 3"};

[db setObject:object forKey:@"Dict Key"];

[db mergeData:@"Key 1:UPDATE:Value X" forKey:@"Dict Key"];
[db mergeData:@"Key 4:INSERT:Value 4" forKey:@"Dict Key"];
[db mergeData:@"Key 2:DELETE" forKey:@"Dict Key"];
[db mergeData:@"Key 1:UPDATE:Value 1 New" forKey:@"Dict Key"];

id result = [db dataForKey:@"Dict Key"];
/**
result = @{@"Key 1" : @"Value 1 New",
		   @"Key 3" : @"Value 3",
		   @"Key 4" : @"Value 4"};
*/
```

## Env & Thread Status

The `RocksDBEnv` allows for modifying the thread pool for backgrond jobs. RocksDB uses this thread pool for compactions and memtable flushes.

```objective-c
RocksDBEnv *dbEnv = [RocksDBEnv envWithLowPriorityThreadCount:12 andHighPriorityThreadCount:4];
RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.env = dbEnv;
}];

// To get a list of all threads
NSArray *threads = dbEnv.threadList;

// "threads" array contains objects of type RocksDBThreadStatus
RocksDBThreadStatus *status = threads[0];
```

## Backup & Restore

To backup a database use the `RocksDBBackupEngine`:

```objective-c
RocksDB *db = ...

RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:@"path/to/backup"];
NSError *error = nil;
[backupEngine createBackupForDatabase:db error:&error];
...
[backupEngine close];
```

To restore a database backup:

```objective-c
RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:@"path/to/backup"];
backupEngine restoreBackupToDestinationPath:@"path/to/db" error:nil];
backupEngine close];

RocksDB *db = [RocksDB databaseAtPath:@"path/to/db"];
...
[db2 close];
```

Backups are incremental and only the new data will be copied to backup directory, so you can:

* Retrieve info about all the backups available
* Restore a specific incremental backup instead of the last one
* Delete specific backups
* Purge all backups keeping the last N backups

```objective-c
RocksDB *db = ...

RocksDBBackupEngine *backupEngine = [[RocksDBBackupEngine alloc] initWithPath:@"path/to/backup"];

[db setData:@"Value 1" forKey:@"A"];
[backupEngine createBackupForDatabase:db error:nil];

[db setData:@"Value 2" forKey:@"B"];
[backupEngine createBackupForDatabase:db error:nil];

[db setData:@"Value 3" forKey:@"C"];
[backupEngine createBackupForDatabase:db error:nil];

// An array containing RocksDBBackupInfo objects
NSArray *backupInfo = backupEngine.backupInfo;

// Restore second backup
[backupEngine restoreBackupWithId:2 toDestinationPath:@"path/to/db" error:nil];

// Delete first backup
[backupEngine deleteBackupWithId:1 error:nil];

// Purge all except the last two
[backupEngine purgeOldBackupsKeepingLast:2 error:nil];
```

## Statistics

You can collect those statistics by creating and setting the `RocksDBStatistics` object in the database options:

```objective-c
RocksDBStatistics *dbStatistics = [RocksDBStatistics new];

RocksDB *db = [RocksDB databaseAtPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.statistics = dbStatistics;
}];
...

[dbStatistics countForTicker:RocksDBTickerBytesRead];
RocksDBStatisticsHistogram *dbGetHistogram = [dbStatistics histogramDataForType:RocksDBHistogramDBGet];
```

Available Tickers and Histograms are defined in `RocksDBStatistics.h`
 
## Properties

The database exports some properties about its state via properties on a per column family level. Available properties are defined in `RocksDBProperties.h`

```objective-c
RocksDB *db = ...

NSString *dbStats = [db valueForProperty:RocksDBPropertyDBStats];
uint64_t sizeActiveMemTable = [db valueForIntProperty:RocksDBIntPropertyCurSizeActiveMemTable];
```

# Configuration <a name="configuration"></a>

Currently only a subset of all RocksDB's available options are wrapped/provided.

> Further options will be added in later versions (mostly when I get the time to experiment with them and figure out what they do)

## ObjectiveRocks DB Options

| Option                      | Description                                                          | Default Value                      |
|-----------------------------|----------------------------------------------------------------------|------------------------------------|
| createIfMissing             | The database will be created if it is missing                        | false                              |
| createMissingColumnFamilies | Missing column families will be automatically created                | false                              |
| errorIfExists               | An error is raised if the database already exists                    | false                              |
| paranoidChecks              | RocksDB will aggressively check consistency of the data              | true                               |
| infoLogLevel                | Log level                                                            | INFO                               |
| maxOpenFiles                | Number of open files that can be used by the DB                      | 5000                               |
| maxWriteAheadLogSize        | Max size of write-ahead logs before force-flushing                   | 0 (= dynamically chosen)           |
| statistics                  | If non-nil, metrics about database operations will be collected      | nil                                |
| disableDataSync             | Contents of manifest and data files wont be synced to stable storage | false                              |
| useFSync                    | Every store to stable storage will issue a fsync                     | false                              |
| maxLogFileSize              | Max size of the info log file, will rotate when exceeded             | 0 (= all logs written to one file) |
| logFileTimeToRoll           | Time for the info log file to roll (in seconds)                      | 0 (disabled)                       |
| keepLogFileNum              | Maximal info log files to be kept                                    | 1000                               |
| bytesPerSync                | Incrementally sync files to disk while they are being written        | 0 (disabled)                       |

## ObjectiveRocks Column Family Options

| Option                      | Description                                                          | Default Value                                  |
|-----------------------------|----------------------------------------------------------------------|------------------------------------------------|
| comparator                  | Used to define the order of keys in the table                        | Lexicographic byte-wise ordering               |
| mergeOperator               | Must be provided for merge operations                                | `nil`                                          |
| writeBufferSize             | Amount of data to build up in memory before writing to disk          | 4 * 1048576 (4MB)                              |
| maxWriteBufferNumber        | The maximum number of write buffers that are built up in memory      | 2                                              |
| minWriteBufferNumberToMerge | The minimum number of write buffers that will be merged together before writing to storage | 1                        |
| compressionType             | Compress blocks using the specified compression algorithm            | Snappy Compression                             |
| prefixExtractor             | If non-nil, the specified function to determine the prefixes for keys will be used | `nil`                            |
| numLevels                   | Number of levels for the DB                                          | 7                                              |
| level0FileNumCompactionTrigger | Compress blocks using the specified compression algorithm         | 4                                              |
| level0SlowdownWritesTrigger | Soft limit on number of level-0 files                                | 20                                             |
| level0StopWritesTrigger     | Maximum number of level-0 files                                      | 24                                             |
| targetFileSizeBase          | Target file size for compaction                                      | 2 * 1048576 (2MB)                              |
| targetFileSizeMultiplier    | Multiplier for sizes of files in different levels                    | 1 (files in different levels will have similar size) |
| maxBytesForLevelBase        | Control maximum total data size for a level                          | 10 * 1048576 (10MB)                            |
| maxBytesForLevelMultiplier  | Multiplier for file size per level                                   | 10                                             |
| expandedCompactionFactor    | Maximum number of bytes in all compacted files                       | 25                                             |
| sourceCompactionFactor      | Maximum number of bytes in all source files to be compacted in a single compaction run               | 1              |
| maxGrandparentOverlapFactor | Control maximum bytes of overlaps in grandparent (i.e., level+2)                                     | 10             |
| softRateLimit               | Puts are delayed 0-1 ms when any level has a compaction score that exceeds this limit                | 0 (disabled)   |
| hardRateLimit               | Puts are delayed 1ms at a time when any level has a compaction score that exceeds this limit         | 0 (disabled)   |
| arenaBlockSize              | Size of one block in arena memory allocation                                                         | 0              |
| disableAutoCompactions      | Disable automatic compactions                                                                        | false          |
| purgeRedundantKvsWhileFlush | Purge duplicate/deleted keys when a memtable is flushed to storage                                   | true           |
| verifyChecksumsInCompaction | If true, compaction will verify checksum on every read that happens as part of compaction            | true           |
| filterDeletes               | Use KeyMayExist API to filter deletes when this is true                                              | false          |
| maxSequentialSkipInIterations | An iteration->Next() sequentially skips over keys with the same user-key unless this option is set | 8              |
| memTableRepFactory          | A factory that provides MemTableRep objects                                                          | `nil`. Internallty RocksDB will use a factory that provides a skip-list-based implementation of `MemTableRep` |
| tableFacotry                | A factory that provides TableFactory objects                                                         | `nil`. Internallty RocksDB will use a block-based table factory that provides a default implementation of TableBuilder and TableReader with default `BlockBasedTableOptions` |
| memtablePrefixBloomBits     | If prefixExtractor is set and bloom_bits is not 0, create prefix bloom for memtable                  | 0              |
| memtablePrefixBloomProbes   | Number of hash probes per key                                                                        | 6              |
| memtablePrefixBloomHugePageTlbSize |  Page size for huge page TLB for bloom in memtable                                            | 0              |
| bloomLocality               |  Control locality of bloom filter probes to improve cache miss rate                                  | 0              |
| maxSuccessiveMerges         | Maximum number of successive merge operations on a key in the memtable                               | 0              |
| minPartialMergeOperands     | The number of partial merge operands to accumulate before partial merge will be performed            | 2              |

## Read Options

| Option                      | Description                                                          | Default Value                      |
|-----------------------------|----------------------------------------------------------------------|------------------------------------|
| verifyChecksums             | Data read will be verified against corresponding checksums           | true                               |
| fillCache                   | whether the read for this iteration be cached in memory              | true                               |

## Write Options

| Option                      | Description                                                          | Default Value                      |
|-----------------------------|----------------------------------------------------------------------|------------------------------------|
| syncWrites                  | Writes will be flushed from buffer before being considered complete  | false                              |
| disableWriteAheadLog        | Writes will not first go to the write ahead log                      | true                               |
| ignoreMissingColumnFamilies | Ignore writes to non-existing column families                        | false                              |

## Table Formats

* `BlockBasedTable`: is the default SST table format in RocksDB.
* `PlainTable`: is a RocksDB's SST file format optimized for low query latency on pure-memory or really low-latency media.
* `CuckooTable`: designed for applications that require fast point lookups but not fast range scans.

## Memtable Formats

* `SkipList`: uses a skip list to store keys. It is the default.
* `Vector`: creates MemTableReps that are backed by an std::vector. On iteration, the vector is sorted. This is useful for workloads where iteration is very rare and writes are generally not issued after reads begin.
* `HashSkipList`: contains a fixed array of buckets, each pointing to a skiplist.
* `HashLinkedList`: creates memtables based on a hash table: it contains a fixed array of buckets, each pointing to either a linked list or a skip list if number of entries inside the bucket exceeds a predefined threshold.
* `Cuckoo`: creates a cuckoo-hashing based mem-table representation. Cuckoo-hash is a closed-hash strategy, in which all key/value pairs are stored in the bucket array itself intead of in some data structures external to the bucket array

For more details visit the wiki [Hash based memtable implementations](https://github.com/facebook/rocksdb/wiki/Hash-based-memtable-implementations)
