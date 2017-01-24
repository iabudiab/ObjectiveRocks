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
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! backupEngine.createBackup(forDatabase: rocks)

		rocks.close()

		let exists = FileManager.default.fileExists(atPath: self.backupPath)
		XCTAssertTrue(exists)
	}

	func testSwift_Backup_BackupInfo() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! backupEngine.createBackup(forDatabase: rocks)

		rocks.close()

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 1);

		let info = backupInfo[0] as! RocksDBBackupInfo

		XCTAssertEqual(info.backupId, 1 as UInt32)
	}

	func testSwift_Backup_BackupInfo_Multiple() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))

		try! backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		try! backupEngine.createBackup(forDatabase: rocks)

		rocks.close()

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 3);

		XCTAssertEqual((backupInfo[0] as AnyObject).backupId, 1 as UInt32)
		XCTAssertEqual((backupInfo[1] as AnyObject).backupId, 2 as UInt32)
		XCTAssertEqual((backupInfo[2] as AnyObject).backupId, 3 as UInt32)
	}

	func testSwift_Backup_PurgeBackups() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		do {
			try backupEngine.createBackup(forDatabase: rocks)
		} catch _ {
		}

		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try!  backupEngine.createBackup(forDatabase: rocks)

		rocks.close()

		try! backupEngine.purgeOldBackupsKeepingLast(2)

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 2);

		XCTAssertEqual((backupInfo[0] as AnyObject).backupId, 2 as UInt32)
		XCTAssertEqual((backupInfo[1] as AnyObject).backupId, 3 as UInt32)
	}

	func testSwift_Backup_DeleteBackup() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try!  backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! backupEngine.createBackup(forDatabase: rocks)

		rocks.close()

		try!  backupEngine.deleteBackup(withId: 2)

		let backupInfo = backupEngine.backupInfo()

		XCTAssertNotNil(backupInfo)
		XCTAssertEqual(backupInfo.count, 2);

		XCTAssertEqual((backupInfo[0] as AnyObject).backupId, 1 as UInt32)
		XCTAssertEqual((backupInfo[1] as AnyObject).backupId, 3 as UInt32)
	}

	func testSwift_Backup_Restore() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try!  backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 10"), forKey: Data.from(string: "key 1"))
		try! rocks.setData(Data.from(string: "value 20"), forKey: Data.from(string: "key 2"))
		try! rocks.setData(Data.from(string: "value 30"), forKey: Data.from(string: "key 3"))

		rocks.close()

		try! backupEngine.restoreBackup(toDestinationPath: self.restorePath)

		let backupRocks = RocksDB.database(atPath: restorePath, andDBOptions: nil)

		XCTAssertNotNil(backupRocks)
		XCTAssertEqual(try! backupRocks?.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"))
		XCTAssertEqual(try! backupRocks?.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"))
		XCTAssertEqual(try! backupRocks?.data(forKey: Data.from(string: "key 3")), Data.from(string: "value 3"))

		backupRocks?.close()
	}

	func testSwift_Backup_Restore_Specific() {
		rocks = RocksDB.database(atPath: self.path, andDBOptions: { (options) -> Void in
			options.createIfMissing = true
		})

		let backupEngine = RocksDBBackupEngine(path: self.backupPath)

		try! rocks.setData(Data.from(string: "value 1"), forKey: Data.from(string: "key 1"))
		try! backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 2"), forKey: Data.from(string: "key 2"))
		try! backupEngine.createBackup(forDatabase: rocks)

		try! rocks.setData(Data.from(string: "value 3"), forKey: Data.from(string: "key 3"))
		try! backupEngine.createBackup(forDatabase: rocks)

		rocks.close()

		try!  backupEngine.restoreBackup(withId: 1, toDestinationPath: self.restorePath)

		var backupRocks = RocksDB.database(atPath: restorePath, andDBOptions: nil)

		XCTAssertEqual(try! backupRocks?.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"))

		XCTAssertNil(try? backupRocks?.data(forKey: Data.from(string: "key 2")))
		XCTAssertNil(try? backupRocks?.data(forKey: Data.from(string: "key 3")))

		backupRocks?.close()

		try! backupEngine.restoreBackup(withId: 2, toDestinationPath: self.restorePath)

		backupRocks = RocksDB.database(atPath: restorePath, andDBOptions: nil)

		XCTAssertNotNil(backupRocks)
		XCTAssertEqual(try! backupRocks?.data(forKey: Data.from(string: "key 1")), Data.from(string: "value 1"))
		XCTAssertEqual(try! backupRocks?.data(forKey: Data.from(string: "key 2")), Data.from(string: "value 2"))
		XCTAssertNil(try? backupRocks?.data(forKey: Data.from(string: "key 3")))

		backupRocks?.close()
	}
}
