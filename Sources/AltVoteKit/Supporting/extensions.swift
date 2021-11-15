import Foundation

extension Hashable where Self: AnyObject {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}

extension Equatable where Self: AnyObject {
	public static func == (lhs:Self, rhs:Self) -> Bool {
		return lhs === rhs
	}
}

extension UUID: @unchecked Sendable{}
