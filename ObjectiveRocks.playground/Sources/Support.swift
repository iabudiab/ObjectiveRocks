//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

extension Data: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = value.data(using: .utf8)!
	}

	public init(extendedGraphemeClusterLiteral value: String) {
		self = value.data(using: .utf8)!
	}

	public init(unicodeScalarLiteral value: String) {
		self = value.data(using: .utf8)!
	}
}

extension Data: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		var value = value
		self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
	}
}
