# ObjectiveRocks

ObjectiveRocks is an Objective-C wrapper of Facebook's [RocksDB](https://github.com/facebook/rocksdb) - A Persistent Key-Value Store for Flash and RAM Storage. If you are interested in the internals of RocksDB, please refer to the [RocksDB Wiki](https://github.com/facebook/rocksdb/wiki).

ObjectiveRocks provides an easy and straightforward interface to RocksDB and an Objective-C friendly API while abstracting away the underlying C++ implementation, so you don't have to deal with it.

# Usage

## Open and close a database

To open a database you have to specify its location:

```objective-c
RocksDB *db = [[RocksDB alloc] initWithPath:@"path/to/db"];
...
[db close];
```

RocksDB features many configuration settings, that can be specified when opening the database. ObjectiveRocks offers a blocks-based initializer for this purpose, for example:

```objective-c
RocksDB *db = [[RocksDB alloc] initWithPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
	options.maxOpenFiles = 3000;
	options.writeBufferSize = 64 * 1024 * 1024;
	options.maxWriteBufferNumber = 3;
}];
```

The [configuration guide](#configuration) lists all currently available options along with their description.

## Basic Operations

The database provides three basic methods, `Put`, `Get`, and `Delete` to store/query data. Keys and values in RocksDB are arbitrary byte arrays:

```objective-c
RocksDB *db = [[RocksDB alloc] initWithPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
}];

NSData *data = [@"World" dataUsingEncoding:NSUTF8StringEncoding]
NSData *key = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding]

[db storeData:data forKey:key];
NSData *get = [db getDataForKey:key];
[db deleteDataForKey:key];
```

Since working with `NSData` objects is cumbersome, ObjectiveRocks offers an easy mechanism to encode/decode arbitrary objects to/from `NSData`. For example, if you have `NSString` keys and `NSDictionary` objects, you could define your own conversion blocks like this:


```objective-c
RocksDB *db = [[RocksDB alloc] initWithPath:@"path/to/db" andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;

	options.keyEncoder = ^NSData * (id key) {
		return [key dataUsingEncoding:NSUTF8StringEncoding];
	};
	options.keyDecoder = ^id (NSData *data) {
		return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	};
	options.valueEncoder = ^NSData * (id key, id value) {
		return [NSJSONSerialization dataWithJSONObject:value
											   options:0
												 error:nil];
	};
	options.valueDecoder = ^id (id key, NSData *data) {
		return [NSJSONSerialization JSONObjectWithData:data
											   options:NSJSONReadingMutableContainers
												 error:nil];
	};
}];

NSDictionary *object = @{@"Objective": @"Rocks"};

[db setObject:object forKey:@"Hello"];
NSMutableDictionary *dictionary = [db objectForKey:@"Hello"];
[db deleteObjectForKey:@"Hello"];
```

The `valueEncoder` and `valueDecoder` blocks take the `key` as first parameter to allow for multiplexing the conversion, i.e. storing different kinds of objects depending on the given `key`.

> All further examples will use the `id`-based API assuming that the key-value encoders are in place

### Read & Write Errors

Database operations can be passed a `NSError` reference to check for any errors that have occurred:

```objective-c
NSError *error = nil;

[db setObject:object forKey:key error:&error];
NSMutableDictionary *dictionary = [db objectForKey:@"Hello" error:&error];
[db deleteObjectForKey:@"Hello" error:&error];
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

[db objectForKey:aKey readOptions:^(RocksDBReadOptions *readOptions) {
	readOptions.verifyChecksums = YES;
	readOptions.fillCache = NO;
}];
```

Default options can also be set on a DB instance:

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

## Atomic Updates

You can atomically apply a set of updates to the database using a `WriteBatch`. There are two ways to use a `WriteBatch`:

* An inline block-based approach:

```objective-c
[db setObject:@"Value 1" forKey:@"Key 1"];

[db performWriteBatch:^(RocksDBWriteBatch *batch, RocksDBWriteOptions *writeOptions) {
	[batch setObject:@"Value 2" forKey:@"Key 2"];
	[batch setObject:@"Value 3" forKey:@"Key 3"];
	[batch deleteObjectForKey:@"Key 1"];
}];
```

* Via a `WriteBatch` instance, which may be more flexible for "scattered" logic:

```objective-c
[db setObject:@"Value 1" forKey:@"Key 1"];

RocksDBWriteBatch *batch = [RocksDBWriteBatch new];
[batch setObject:@"Value 2" forKey:@"Key 2"];
[batch setObject:@"Value 3" forKey:@"Key 3"];
[batch deleteObjectForKey:@"Key 1"];
...
[db applyWriteBatch:batch withWriteOptions:^(RocksDBWriteOptions *writeOptions) {
	// write options here
}];
```

## Iteration

Iteration is provided via the `RocksDBIterator` class.

You can either iterate manually:

```objective-c
RocksDBIterator *iterator = [db iterator];
// alternatively, you can get an iterator with specific read options
iterator = [db iteratorWithReadOptions:^(RocksDBReadOptions *readOptions) {
	// read options here
}];

for ([iterator seekToKey:@"start"]; [iterator isValid]; [iterator next]) {
	NSLog(@"%@: %@", [iterator key], [iterator value]);
	// iterates all keys starting from key "start" 
}
```

or use one of the provided enumeration-blocks:

```objective-c
[db setObject:@"Value 1" forKey:@"A"];
[db setObject:@"Value 2" forKey:@"B"];
[db setObject:@"Value 3" forKey:@"C"];
[db setObject:@"Value 3" forKey:@"D"];

RocksDBIterator *iterator = [db iterator];

[db enumerateKeysUsingBlock:^(id key, BOOL *stop) {
	NSLog(@"%@: %@", key, [db objectForKey:key]);
	// A, B, C, D
}];

// reverse enumeration
[db enumerateKeysInReverse:YES usingBlock:^(id key, BOOL *stop) {
	NSLog(@"%@: %@", key, [db objectForKey:key]);
	// D, C, B, A
}];

// enumeration in a given key-range [start, end)
RocksDBIteratorKeyRange range = RocksDBMakeKeyRange(@"C", @"A");

[db enumerateKeysInRange:range reverse:YES usingBlock:^(id key, BOOL *stop) {
	NSLog(@"%@: %@", key, [db objectForKey:key]);
	// C, B
}];
```

## Snapshot

A snapshot provide consistent read-only view over the entire state of the key-value store. Do not forget to close the snapshot when it's no longer needed.

```objective-c
[db setObject:@"Value 1" forKey:@"A"];

RocksDBSnapshot *snapshot = [db snapshot];
// alternatively, you can get a snapshot with specific read options
snapshot = [db snapshotWithReadOptions:^(RocksDBReadOptions *readOptions) {
	// read options here
}];

[db deleteObjectForKey:@"A"];
[db setObject:@"Value 2" forKey:@"B"];

NSString *value1 = [snapshot objectForKey:@"A"];
// value1 == @"Value 1"
NSString *value2 = [snapshot objectForKey:@"B"];
// value2 == nil
...
[snapshot close];
```

## Keys Comparator

The keys are ordered within the key-value store according to a user-specified comparator function. The default ordering function for keys orders the bytes lexicographically.

This behavior can be changed by supplying a custom comparator when opening a database using the `RocksDBComparator`.

Say you have `NSString` keys and you want them to be ordered using a case-insensitive, localized, comparison:

```objective-c
RocksDBComparator *localizedKeys = [RocksDBComparator comaparatorWithName:@"LocalizedKeys" andBlock:^int (id key1, id key2) {
	return [key1 localizedCaseInsensitiveCompare:key2];
];
	
RocksDB *db = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
	options.comparator = localizedKeys;
}];
```

> The comparator's name is attached to the database when it is created, and is checked on every subsequent database open. If the name changes, the `open` call will fail. Therefore, change the name if new key format and comparison function are incompatible with existing database, and it is ok to discard the contents of the existing database.

## Merge Operator

A Merge operators is an atomic Read-Modify-Write operation in RocksDB.For a detailed description visit the [Merge Operator](https://github.com/facebook/rocksdb/wiki/Merge-Operator) wiki page in the RocksDB project.

For example we can use a merge operator to append entries to an existing array, instead of reading it completely, updating it and writing it back:

```objective-c
RocksDBMergeOperator *arrayAppend = [RocksDBMergeOperator operatorWithName:@"ArrayAppend" andBlock:^id (id key, id existingValue, id mergeValue) {
	NSMutableArray *result = [NSMutableArray array];
	if (existingValue != nil) {
		result = existingValue;
	}
	[result addObjectsFromArray:mergeValue];
	return result;
}];

RocksDB *db = [[RocksDB alloc] initWithPath:_path andDBOptions:^(RocksDBOptions *options) {
	options.createIfMissing = YES;
	options.mergeOperator = arrayAppend;
}];
```
> Analogous to the `comparator` a database created using one `merge operator` cannot be opened using another.

# Configuration <a name="configuration"></a>

## ObjectiveRocks DBOptions

Currently only a subset of all RocksDB's available options are wrapped/provided.

> Further options will be added in later versions (mostly when I get the time to experiment with them and figure out what they do)

| Option                      | Description                                                          | Default Value                      |
|-----------------------------|----------------------------------------------------------------------|------------------------------------|
| createIfMissing             | The database will be created if it is missing                        | false                              |
| createMissingColumnFamilies | Missing column families will be automatically created                | false                              |
| errorIfExists               | An error is raised if the database already exists                    | false                              |
| paranoidChecks              | RocksDB will aggressively check consistency of the data              | true                               |
| infoLogLevel                | Log level                                                            | INFO                               |
| maxOpenFiles                | Number of open files that can be used by the DB                      | 5000                               |
| maxWriteAheadLogSize        | Max size of write-ahead logs before force-flushing                   | 0 (= dynamically chosen)           |
| disableDataSync             | Contents of manifest and data files wont be synced to stable storage | false                              |
| useFSync                    | Every store to stable storage will issue a fsync                     | false                              |
| maxLogFileSize              | Max size of the info log file, will rotate when exceeded             | 0 (= all logs written to one file) |
| logFileTimeToRoll           | Time for the info log file to roll (in seconds)                      | 0 (disabled)                       |
| keepLogFileNum              | Maximal info log files to be kept                                    | 1000                               |
| bytesPerSync                | Incrementally sync files to disk while they are being written        | 0 (disabled)                       |
| writeBufferSize             | Amount of data to build up in memory before writing to disk          | 4MB                                |
| maxWriteBufferNumber        | The maximum number of write buffers that are built up in memory      | 2                                  | 
| compressionType             | Compress blocks using the specified compression algorithm            | Snappy Compression                 |

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
| timeoutHint                 | Timeout hint for write operation                                     | 0 (no timeout)                     |
| ignoreMissingColumnFamilies | Ignore writes to non-existing column families                        | false                              |
