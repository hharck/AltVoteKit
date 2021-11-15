public struct TieBreaker: normalTieBreakable{
	internal init(name: String, id: String, closure: @Sendable @escaping ([SingleVote], [Option], Int) -> [Option : TieBreak]) {
		self.name = name
		self.id = id
		self.closure = closure
	}
	
	
	/// The name of the TieBreaker
	public let name: String
	
	/// The id of the TieBreaker
	public let id: String
	
	/// Returns every vote in violation of the validator
	private var closure: @Sendable (_ votes: [SingleVote], _ options: [Option], _ optionsLeft: Int) -> [Option : TieBreak]
	
	
	/// Run the tie breaker
	/// - Parameters:
	///   - votes: The votes cast
	///   - options: The options that are in a tie
	///   - optionsLeft: The total number of options left
	/// - Returns: Options and their status
	public func breakTie(votes: [SingleVote], options: [Option], optionsLeft: Int) -> [Option : TieBreak] {
		assert(options.count <= optionsLeft)
		if options.isEmpty{
			return [:]
		} else {
			let result = closure(votes, options, optionsLeft)
			assert(Set(result.keys) == Set(options), "Tie breaker not returning a value for every option")
			return result
		}
	}
}
