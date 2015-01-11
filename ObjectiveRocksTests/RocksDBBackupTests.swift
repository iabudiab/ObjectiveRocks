//
//  RocksDBBackupTests.swift
//  ObjectiveRocks
//
//  Created by Iska on 17/01/15.
//  Copyright (c) 2015 BrainCookie. All rights reserved.
//

import XCTest

class RocksDBBackupTests : RocksDBTests {

	func testSwift_Backup_Create() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.close()

		let exists = NSFileManager.defaultManager().fileExistsAtPath(self.backupPath)
		XCTAssertTrue(exists)
	}

	func testSwift_Backup_BackupInfo() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.close()

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 1);

		let info = backupInfo[0] as RocksDBBackupInfo

		XCTAssertEqual(info.backupId, 1 as UInt32)
	}

	func testSwift_Backup_BackupInfo_Multiple() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.close()

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 3);

		XCTAssertEqual(backupInfo[0].backupId, 1 as UInt32)
		XCTAssertEqual(backupInfo[1].backupId, 2 as UInt32)
		XCTAssertEqual(backupInfo[2].backupId, 3 as UInt32)
	}

	func testSwift_Backup_PurgeBackups() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.close()

		backupEngine.purgeOldBackupsKeepingLast(2, error: nil)

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 2);

		XCTAssertEqual(backupInfo[0].backupId, 2 as UInt32)
		XCTAssertEqual(backupInfo[1].backupId, 3 as UInt32)
	}

	func testSwift_Backup_DeleteBackup() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.close()

		backupEngine.deleteBackupWithId(2, error: nil)

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 2);

		XCTAssertEqual(backupInfo[0].backupId, 1 as UInt32)
		XCTAssertEqual(backupInfo[1].backupId, 3 as UInt32)
	}

	func testSwift_Backup_Restore() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		rocks.setData(Data("value 3"), forKey: Data("key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 10"), forKey: Data("key 1"))
		rocks.setData(Data("value 20"), forKey: Data("key 2"))
		rocks.setData(Data("value 30"), forKey: Data("key 3"))

		rocks.close()

		backupEngine.restoreBackupToDestinationPath(self.restorePath, error: nil)

		let backupRocks = RocksDB(path: restorePath)

		XCTAssertEqual(backupRocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertEqual(backupRocks.dataForKey(Data("key 2")), Data("value 2"))
		XCTAssertEqual(backupRocks.dataForKey(Data("key 3")), Data("value 3"))

		backupRocks.close()
	}

	func testSwift_Backup_Restore_Specific() {
		rocks = RocksDB(path: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		rocks.setData(Data("value 1"), forKey: Data("key 1"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 2"), forKey: Data("key 2"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.setData(Data("value 3"), forKey: Data("key 3"))
		backupEngine.createBackupForDatabase(rocks, error: nil)

		rocks.close()

		backupEngine.restoreBackupWithId(1, toDestinationPath: self.restorePath, error: nil)

		var backupRocks = RocksDB(path: restorePath)

		XCTAssertEqual(backupRocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertNil(backupRocks.dataForKey(Data("key 2")))
		XCTAssertNil(backupRocks.dataForKey(Data("key 3")))

		backupRocks.close()

		backupEngine.restoreBackupWithId(2, toDestinationPath: self.restorePath, error: nil)

		backupRocks = RocksDB(path: restorePath)

		XCTAssertEqual(backupRocks.dataForKey(Data("key 1")), Data("value 1"))
		XCTAssertEqual(backupRocks.dataForKey(Data("key 2")), Data("value 2"))
		XCTAssertNil(backupRocks.dataForKey(Data("key 3")))

		backupRocks.close()
	}
}
