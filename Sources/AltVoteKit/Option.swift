import Foundation

public struct Option: Hashable, Codable{
	public var name: String
	public var subTitle: String?
	var customData: [String: Data]
	
	public init(_ name: String, subTitle: String? = nil, costumData: [String: Data]? = nil){
		self.name = name
		self.subTitle = subTitle
		self.customData = costumData ?? [:]
	}
}
