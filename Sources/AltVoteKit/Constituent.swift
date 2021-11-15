import Foundation
public struct Constituent: Hashable, Codable, Sendable{
	public var name: String?
	public var identifier: String
	public var id: UUID
	
	init(name: String? = nil, identifier: String){
		self.name = name
		self.identifier = identifier
		self.id = UUID()
	}
}

extension Constituent: ExpressibleByStringLiteral{
	public init(stringLiteral value: String){
		self.init(identifier: value)
	}

	
}
