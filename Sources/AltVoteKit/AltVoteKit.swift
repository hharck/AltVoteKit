public typealias UserID = String

protocol AltVote: Actor{
	func validate() -> [ValidationResult]
	func count(force: Bool, excluding: [Option]) async throws -> [Option: UInt]

	var options: [Option] {get set}
	var votes: [SingleVote] {get set}
	var validators: [Validateable] {get set}
	var eligibleUsers: Set<UserID> {get set}
	
	/// Rules for breaking a tie, applied in the order given.
	var tieBreakingRules: [TieBreakable] {get set}

	init(options: [Option], votes: [SingleVote], validators: [Validateable], eligibleUsers: Set<UserID>, tieBreakingRules: [TieBreakable])
}

extension AltVote{
	public func validate() -> [ValidationResult] {
		guard !votes.isEmpty else {
			return [ValidationResult(name: "No votes cast", errors: [])]
		}
		return validators.map{ validator -> ValidationResult in
			validator.validate(votes, eligibleUsers, allOptions: options)
		}
	}
	
	
	
	/// Counts the number of highest priority votes given to an option
	/// - Parameters:
	///   - force: Wether to count without regard to validations
	///   - excluding: The options not relevant to this count
	/// - Returns: The number of votes for each option
	public func count(force: Bool = false, excluding: [Option] = []) async throws -> [Option: UInt]{
		// Checks that all votes are valid
		if !force{
			let validationResults = self.validate()
			guard validationResults.countErrors == 0 else {
				throw validationResults
			}
		}

		//Removes all excluded options_
		let excludingVotes = votes.compactMap { vote -> SingleVote? in
			var vote = vote
			vote.rankings = vote.rankings.filter { option in
				//Keeps options that is not in excluding
				!excluding.contains(option)
			}
			//If all votes have been excluded this vote will not continue into 'excludingVotes'
			guard !vote.rankings.isEmpty else {
				return nil
			}
			return vote
		}
		
		//Counts the number og highest priority votes for each candidate
		return excludingVotes.reduce(into: [Option: UInt]()) { partialResult, vote in
			let primaryOption = vote.rankings.first!
			
			if partialResult[primaryOption] == nil {
				partialResult[primaryOption] = 1
			} else {
				partialResult[primaryOption]! += 1
			}
		}
	}
	
	func setVotes(_ votes: [SingleVote]) async{
		self.votes = votes
	}
	
	func setOptions(_ options: [Option]) async{
		self.options = options
	}
}

actor Vote: AltVote{
	init(options: [Option], votes: [SingleVote], validators: [Validateable], eligibleUsers: Set<UserID>, tieBreakingRules: [TieBreakable]) {
		self.options = options
		self.votes = votes
		self.validators = validators
		self.eligibleUsers = eligibleUsers
		self.tieBreakingRules = tieBreakingRules
	}
	
	var options: [Option] = []
	var votes: [SingleVote] = []
	var validators: [Validateable] = []
	var eligibleUsers: Set<UserID> = []
	var tieBreakingRules: [TieBreakable] = []
	
	func count(force: Bool, exclude: [Option]) -> [Option] {
		return []
	}
}
