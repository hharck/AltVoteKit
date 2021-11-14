import Foundation
extension AltVote{
	/// Validates that the entire vote follows the assertings put in the validators array
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
			
			// If any validation has en error, thrwo it
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
	//MARK: Votes
	/// Sets the votes property, overriding any existing information
	public func setVotes(_ votes: [SingleVote]) async{
		self.votes = votes
	}
	
	/// Adds a vote to the list of votes
	public func addVotes(_ vote: SingleVote) async{
		self.votes.append(vote)
	}
	
	/// Adds a set of votes to the list of votes
	public func addVotes(_ votes: [SingleVote]) async{
		self.votes += votes
	}
	
	/* These may break the expectations of some validators
	/// Defines the possible options for the votes; may override old votes
	public func setOptions(_ options: [Option]) async{
		self.options = options
	}
	
	/// Adds another option to the vote
	public func addOptions(_ option: Option) async{
		self.options.append(option)
	}
	
	/// Adds a set of options to the vote
	public func addOptions(_ options: [Option]) async{
		self.options += options
	}
	*/
	 
	//MARK: Voters
	/// Sets the eligible voters property, overriding any existing information
	public func setEligigbleVoters(_ voters: Set<UserID>) async{
		self.eligibleVoters = voters
	}
	
	/// Adds an eligible voter
	public func addEligigbleVoters(_ voter: UserID) async{
		self.eligibleVoters.insert(voter)
	}
	
	/// Adds multiple eligible voters
	public func addEligigbleVoters(_ voters: Set<UserID>) async{
		self.eligibleVoters.formUnion(voters)
	}
	
	//MARK: Custom data
	public func setData(key: String, value: String?) async {
		self.customData[key] = value
	}
	
	/// Retrieves customData for the given key
	public func getData(key: String) async -> String?{
		self.customData[key]
	}
	
	//MARK: Options
	/// Retrieves an array of options
	public func getAllOptions() async -> [Option]{
		self.options
	}
	
	
}

