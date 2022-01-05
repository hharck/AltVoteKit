import VoteKit
/// Defines the vote of a single person
public struct SingleVote: VoteStub{
	public var isBlank: Bool {rankings.isEmpty}
	public var constituent: Constituent
	
	public var rankings: [VoteOption]
	
	public init(_ constituent: Constituent, rankings: [VoteOption]){
		self.constituent = constituent
		self.rankings = rankings
	}
	
	/// Used for creating a constituent that hasn't voted
	public init(bareBonesVote constituent: Constituent){
		self.constituent = constituent
		self.rankings = []
	}
}

// CSV
extension SingleVote{
	//Format: https://github.com/vstenby/AlternativeVote/blob/main/KABSDemo.csv
	public func csvValueFor(option: VoteOption) -> String {
		for i in 0..<rankings.count{
			if rankings[i] == option{
				return "\(i + 1).0"
			}
		}
		return ""
	}
	
	//Expecting the following format: https://github.com/vstenby/AlternativeVote/blob/main/KABSDemo.csv
	public static func fromCSVLine(values: [String], options: [VoteOption], constituent: Constituent) -> SingleVote? {
		guard values.count == options.count else {
			return nil
		}
		var errorFlag = false
		let rankings = zip(options, values)
			.compactMap{ option, strVal -> (VoteOption, Int)? in
				let strVal = strVal.hasSuffix(".0") ? String(strVal.dropLast(2)) : strVal
				
				if strVal == ""{
					return nil
				}
				
				// Removes".0"
				guard let val = Int(strVal) else{
					errorFlag = true
					return nil
				}
				
				return (option,val)
			}
			.sorted {
				$0.1 < $1.1
			}
			.map(\.0)
		
		if errorFlag{
			return nil
		}
		
		return self.init(constituent, rankings: rankings)
	}
}
