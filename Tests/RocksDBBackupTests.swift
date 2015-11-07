//
//  RocksDBBackupTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 17/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest
import ObjectiveRocks

class RocksDBBackupTests : RocksDBTests {

	func testSwift_Backup_Create() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! backupEngine.createBackupForDatabase(rocks)

		rocks.close()

		let exists = NSFileManager.defaultManager().fileExistsAtPath(self.backupPath)
		XCTAssertTrue(exists)
	}

	func testSwift_Backup_BackupInfo() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! backupEngine.createBackupForDatabase(rocks)

		rocks.close()

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 1);

		let info = backupInfo[0] as! RocksDBBackupInfo

		XCTAssertEqual(info.backupId, 1 as UInt32)
	}

	func testSwift_Backup_BackupInfo_Multiple() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))

		try! backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		try! backupEngine.createBackupForDatabase(rocks)

		rocks.close()

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 3);

		XCTAssertEqual(backupInfo[0].backupId, 1 as UInt32)
		XCTAssertEqual(backupInfo[1].backupId, 2 as UInt32)
		XCTAssertEqual(backupInfo[2].backupId, 3 as UInt32)
	}

	func testSwift_Backup_PurgeBackups() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		do {
			try backupEngine.createBackupForDatabase(rocks)
		} catch _ {
		}

		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))
		try!  backupEngine.createBackupForDatabase(rocks)

		rocks.close()

		try! backupEngine.purgeOldBackupsKeepingLast(2)

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 2);

		XCTAssertEqual(backupInfo[0].backupId, 2 as UInt32)
		XCTAssertEqual(backupInfo[1].backupId, 3 as UInt32)
	}

	func testSwift_Backup_DeleteBackup() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try!  backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))
		try! backupEngine.createBackupForDatabase(rocks)

		rocks.close()

		try!  backupEngine.deleteBackupWithId(2)

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 2);

		XCTAssertEqual(backupInfo[0].backupId, 1 as UInt32)
		XCTAssertEqual(backupInfo[1].backupId, 3 as UInt32)
	}

	func testSwift_Backup_Restore() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try!  backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 10"), forKey: Data("key 1"))
		try! rocks.setData(Data("value 20"), forKey: Data("key 2"))
		try! rocks.setData(Data("value 30"), forKey: Data("key 3"))

		rocks.close()

		try! backupEngine.restoreBackupToDestinationPath(self.restorePath)

		let backupRocks = RocksDB.databaseAtPath(restorePath, andDBOptions: nil)

		XCTAssertEqual(try! backupRocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertEqual(try! backupRocks.dataForKey(Data("key 2")), Data("value 2"))
		XCTAssertEqual(try! backupRocks.dataForKey(Data("key 3")), Data("value 3"))

		backupRocks.close()
	}

	func testSwift_Backup_Restore_Specific() {
		rocks = RocksDB.databaseAtPath(self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data("value 1"), forKey: Data("key 1"))
		try! backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 2"), forKey: Data("key 2"))
		try! backupEngine.createBackupForDatabase(rocks)

		try! rocks.setData(Data("value 3"), forKey: Data("key 3"))
		try! backupEngine.createBackupForDatabase(rocks)

		rocks.close()

		try!  backupEngine.restoreBackupWithId(1, toDestinationPath: self.restorePath)

		var backupRocks = RocksDB.databaseAtPath(restorePath, andDBOptions: nil)

		XCTAssertEqual(try! backupRocks.dataForKey(Data("key 1")), Data("value 1"))

		XCTAssertNil(try? backupRocks.dataForKey(Data("key 2")))
		XCTAssertNil(try? backupRocks.dataForKey(Data("key 3")))

		backupRocks.close()

		try! backupEngine.restoreBackupWithId(2, toDestinationPath: self.restorePath)

		backupRocks = RocksDB.databaseAtPath(restorePath, andDBOptions: nil)

		XCTAssertEqual(try! backupRocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertEqual(try! backupRocks.dataForKey(Data("key 2")), Data("value 2"))
		XCTAssertNil(try? backupRocks.dataForKey(Data("key 3")))

		backupRocks.close()
	}
}
