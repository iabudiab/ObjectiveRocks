//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import ObjectiveRocks

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let url = XCPlaygroundSharedDataDirectoryURL.URLByAppendingPathComponent("Rocks")
try NSFileManager.defaultManager().removeItemAtPath(url.path!)

let rocks = RocksDB.databaseAtPath(url.path) { options in
	options.createIfMissing = true
	options.keyType = .NSString
	options.valueEncoder = { key, number in
		var value: Int = (number as! NSNumber).integerValue
		return NSData(bytes: &value, length: sizeof(Int))
	}
	options.valueDecoder = { key, data in
		var value: Int = 0
		data.getBytes(&value, length: sizeof(Int))
		return NSNumber(integer: value)
	}
}

guard rocks != nil else {
	XCPlaygroundPage.currentPage.finishExecution()
}

try rocks.performWriteBatch { batch, writeOptions -> Void in
	batch.setData(-10, forKey: "0001")
	batch.setData(9, forKey: "0011")
	batch.setData(-8, forKey: "0002")
	batch.setData(7, forKey: "0003")
	batch.setData(-6, forKey: "0012")
	batch.setData(5, forKey: "0004")
	batch.setData(-4, forKey: "0005")
	batch.setData(3, forKey: "0006")
	batch.setData(-2, forKey: "0007")
	batch.setData(11, forKey: "0008")
	batch.setData(1, forKey: "0009")
}

rocks.iterator().enumerateKeysWithPrefix("000") { key, stop -> Void in
	do {
		let value = try rocks.objectForKey(key)

		if value.integerValue > 10 {
			var shouldStop: ObjCBool = true
			stop.initialize(shouldStop)
		}
	} catch {}
}

XCPlaygroundPage.currentPage.finishExecution()
