import Foundation
public typealias ConstituentID = String
public struct Constituent: Hashable, Codable, Sendable{
	public var name: String?
	public var identifier: ConstituentID
	
	public init(name: String? = nil, identifier: ConstituentID){
		self.name = name
		self.identifier = identifier
	}
}

extension Constituent: ExpressibleByStringLiteral{
	public init(stringLiteral value: ConstituentID){
		self.init(identifier: value)
	}

	
}
