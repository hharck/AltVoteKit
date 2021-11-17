public struct TieBreaker: normalTieBreakable{
	internal init(name: String, id: String, closure: @Sendable @escaping ([SingleVote], [VoteOption], Int) -> [VoteOption : TieBreak]) {
		self.name = name
		self.id = id
		self.closure = closure
	}
	
	
	/// The name of the TieBreaker
	public let name: String
	
	/// The id of the TieBreaker
	public let id: String
	
	/// Returns every vote in violation of the validator
	private var closure: @Sendable (_ votes: [SingleVote], _ options: [VoteOption], _ optionsLeft: Int) -> [VoteOption : TieBreak]
	
	
	/// Run the tie breaker
	/// - Parameters:
	///   - votes: The votes cast
	///   - options: The options that are in a tie
	///   - optionsLeft: The total number of options left
	/// - Returns: Options and their status
	public func breakTie(votes: [SingleVote], options: [VoteOption], optionsLeft: Int) -> [VoteOption : TieBreak] {
		assert(options.count <= optionsLeft)
		if options.isEmpty{
			return [:]
		} else {
			let result = closure(votes, options, optionsLeft)

			//Only checked during debug builds
			assert(Set(result.keys) == Set(options), "Tiebreaker not returning a value for every option")
			return result
		}
	}
	enum TieBreakingError: Error{
		case noTBwasAbleToBreakTie
	}
}


