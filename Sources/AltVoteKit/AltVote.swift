public typealias UserID = String

protocol AltVote: Actor{
	func validate() -> [ValidationResult]
	func count(force: Bool, excluding: [Option]) async throws -> [Option: UInt]

	var options: [Option] {get set}
	var votes: [SingleVote] {get set}
	var validators: [Validateable] {get set}
	var eligibleVoters: Set<UserID> {get set}
	
	/// Rules for breaking a tie, applied in the order given.
	var tieBreakingRules: [TieBreakable] {get set}

	init(options: [Option], votes: [SingleVote], validators: [Validateable], eligibleVoters: Set<UserID>, tieBreakingRules: [TieBreakable])
}

extension AltVote{	
	public func validate() -> [ValidationResult] {
		guard !votes.isEmpty else {
			return [ValidationResult(name: "No votes cast", errors: [])]
		}
		print(votes.count)
		return validators.map{ validator -> ValidationResult in
			validator.validate(votes, eligibleVoters, allOptions: options)
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
		
		//Sets zero votes for all allowed options
		let dict = Set(options).subtracting(excluding).reduce(into: [Option: UInt]()) { partialResult, option in
			partialResult[option] = 0
		}
		
		//Counts the number of highest priority votes for each candidate
		return excludingVotes.reduce(into: dict) { partialResult, vote in
			let primaryOption = vote.rankings.first!
			partialResult[primaryOption]! += 1
		}
	}
	
}

//Setters
extension AltVote{
	public func setVotes(_ votes: [SingleVote]) async{
		self.votes = votes
	}
	
	public func addVotes(_ vote: SingleVote) async{
		self.votes.append(vote)
	}
	
	public func addVotes(_ votes: [SingleVote]) async{
		self.votes += votes
	}
	
	public func setOptions(_ options: [Option]) async{
		self.options = options
	}
	
	public func addOptions(_ option: Option) async{
		self.options.append(option)
	}
	
	public func addOptions(_ options: [Option]) async{
		self.options += options
	}
	
	public func setEligigbleVoters(_ voters: Set<UserID>) async{
		self.eligibleVoters = voters
	}
	
	public func addEligigbleVoters(_ voter: UserID) async{
		self.eligibleVoters.insert(voter)
	}
	
	public func addEligigbleVoters(_ voters: Set<UserID>) async{
		self.eligibleVoters.formUnion(voters)
	}
	
}

