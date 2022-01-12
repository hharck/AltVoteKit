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
    public func csvValueFor(config: CSVConfiguration, option: VoteOption) -> String {
		for i in 0..<rankings.count{
			if rankings[i] == option{
                if let suffix = config.specialKeys["Alternative vote priority suffix"]{
                    return "\(i + 1)" + suffix
                } else {
                    return "\(i + 1)"
                }
			}
		}
		return ""
	}
	
    public static func fromCSVLine(config: CSVConfiguration, values: [String], options: [VoteOption], constituent: Constituent) -> SingleVote? {
		guard values.count == options.count else {
			return nil
		}
		var errorFlag = false
        let defaultSuffix = config.specialKeys["Alternative vote priority suffix"]
		let rankings = zip(options, values)
			.compactMap{ option, str -> (VoteOption, Int)? in
                let strVal: String
                
                // Removes suffixes defined with the "Alternative vote priority suffix" key in the configuration
                if defaultSuffix != nil{
                    strVal = str.hasSuffix(defaultSuffix!) ? String(str.dropLast(defaultSuffix!.count)) : str
                } else {
                    strVal = str
                }
				
				if strVal == ""{
					return nil
				}
				
				
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
