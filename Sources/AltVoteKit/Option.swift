import Foundation

public struct Option: Hashable, Equatable, Codable{
	public var name: String
	public var subTitle: String?
	public var customData: [String: Data]
	public let id: UUID
	public init(_ name: String, subTitle: String? = nil, customData: [String: Data]? = nil){
		self.name = name
		self.subTitle = subTitle
		self.customData = customData ?? [:]
		self.id = UUID()
	}
}
