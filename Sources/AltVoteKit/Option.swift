import Foundation

/// Defines a candidate in vote
public struct Option: Hashable, Equatable, Codable{
	public let id: UUID
	public var name: String
	public var subTitle: String?
	public var customData: [String: Data]
	
	public init(_ name: String, subTitle: String? = nil, customData: [String: Data]? = nil){
		self.name = name
		self.subTitle = subTitle
		self.customData = customData ?? [:]
		self.id = UUID()
	}
}

//Adds support for creating defining options as a simple array of strings; mostly used for testing purposes
extension Option: ExpressibleByStringLiteral{
	public init(stringLiteral value: String) {
		self.init(value)
	}
}
