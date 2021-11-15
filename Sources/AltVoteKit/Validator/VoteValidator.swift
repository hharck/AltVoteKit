public struct VoteValidator: Validateable{
	public typealias closureType = @Sendable ([SingleVote], _ eligibleUsers: Set<UserID>, _ options: [VoteOption]) -> [SingleVote]
	
	/// The id of the validator
	public let id: String
	
	/// A name for use in UI
	public let name: String
	
	/// Generates an error string for why a vote wasn't validated
	private let offenseText: @Sendable (_ for: SingleVote, _ options: [VoteOption]) -> String
	
	/// Returns every vote in violation of the validator
	private var closure: closureType
	
	
	/// Validates the given votes
	/// - Parameters:
	///   - votes: The votes to validate
	///   - eligibleUsers: The users allowed to vote
	/// - Returns: An array of error strings. Can be used along with \.name when showing the errors on the frontend
	public func validate(_ votes: [SingleVote], _ eligibleUsers: Set<UserID>, allOptions: [VoteOption]) -> VoteValidationResult{
		let offenders = closure(votes, eligibleUsers, allOptions)
		let offenseTexts = offenders.map{offenseText($0, [])}
		return VoteValidationResult(name: self.id, errors: offenseTexts)
	}

	public init(id: String, name: String, offenseText: @Sendable @escaping (_ for: SingleVote, _ options: [VoteOption]) -> String, closure: @escaping closureType){
		self.id = id
		self.name = name
		self.offenseText = offenseText
		self.closure = closure
	}
}

extension VoteValidator: Equatable{
	public static func == (lhs: VoteValidator, rhs: VoteValidator) -> Bool {
		//Assuming all names are unique
		lhs.id == rhs.id
	}
}


