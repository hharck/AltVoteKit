import Foundation
extension AltVote{
	internal var requiredValidators: [Validateable] {
		[VoteValidator.oneVotePerUser]
	}
	/// Validates that the entire vote follows the assertings put in the validators array
	public func validate() -> [VoteValidationResult] {
		guard !votes.isEmpty else {
			return [VoteValidationResult(name: "No votes cast", errors: [])]
		}
		let allValidators = requiredValidators + validators
		return allValidators.map{ validator -> VoteValidationResult in
			validator.validate(votes, eligibleVoters, allOptions: options)
		}
	}
	
	/// Counts the number of highest priority votes given to an option
	/// - Parameters:
	///   - force: Wether to count without regard to validations
	///   - excluding: The options not relevant to this count
	/// - Returns: The number of votes for each option
	public func count(force: Bool = false, excluding: [VoteOption] = []) async throws -> [VoteOption: UInt]{
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
				//Filters out options that is in the excluding array
				!excluding.contains(option)
			}
			//If all votes have been excluded this vote will not continue into 'excludingVotes'
			guard !vote.rankings.isEmpty else {
				return nil
			}
			return vote
		}
		
		//Sets zero votes for all allowed options
		let dict = Set(options)
			.subtracting(excluding)
			.reduce(into: [VoteOption: UInt]()) { partialResult, option in
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
	//MARK: Set votes
	/// Sets the votes property, overriding any existing information
	/// - Parameter votes: The votes to set
	/// - Returns: Whether all userIDs were unique
	@discardableResult public func setVotes(_ votes: [SingleVote]) async -> Bool{
		guard votes.map(\.user).nonUniques.isEmpty else {
			return false
		}
		
		self.votes = votes
		return true
	}
	
	/// Adds a vote to the list of votes
	/// - Parameter vote: The vote to set
	/// - Returns: Whether all userIDs were unique
	@discardableResult public func addVotes(_ vote: SingleVote) async -> Bool{
		let user = vote.user
		if self.votes.contains(where: {$0.user == user}){
			return false
		}
		
		self.votes.append(vote)
		return true
	}
	
	public func resetVoteForUser(_ user: Constituent){
		self.votes.removeAll(where: {vote in
			vote.user == user
		})
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
	public func setEligigbleVoters(_ voters: Set<Constituent>) async{
		self.eligibleVoters = voters
	}
	
	/// Adds an eligible voter
	public func addEligigbleVoters(_ voter: Constituent) async{
		self.eligibleVoters.insert(voter)
	}
	
	/// Adds multiple eligible voters
	public func addEligigbleVoters(_ voters: Set<Constituent>) async{
		self.eligibleVoters.formUnion(voters)
	}
	
	//MARK: Custom data
	public func setData(key: String, value: String?) async {
		self.customData[key] = value
	}
}

//Getters
extension AltVote{
	/// Retrieves customData for the given key
	public func getData(key: String) async -> String?{
		self.customData[key]
	}
	
	//MARK: Options
	/// Retrieves an array of options
	public func getAllOptions() async -> [VoteOption]{
		self.options
	}
	
	
	/// Checks if a given userID already has voted in this vote
	public func hasUserVoted(_ user: Constituent) async -> Bool{
		votes.contains(where: {
			$0.user == user
		})
	}
}


// Debug data
extension AltVote{
	// Finds the number of votes for each priority for each option
	public func debugCount() async -> [VoteOption: [Int:Int]]{
		// priority: no. of votes for that priority
		var d = [Int: Int]()
		//Sets all priorities to zero votes
		for i in 1...options.count{
			d[i] = 0
		}
		
		// Creates a list of options and the number of votes on each priority
		// 		[voting option: [the rank : number of votes for this rank]
		var priorities: [VoteOption: [Int:Int]] = options.reduce(into: [VoteOption: [Int:Int]]()) { partialResult, option in
			partialResult[option] = d
		}
		
		votes.forEach { vote in
			for i in 0..<vote.rankings.count{
				let option = vote.rankings[i]
				priorities[option]![i+1]! += 1
			}
		}
		
		return priorities
		
	}
	
	public func debugCount2() async -> [[String]]{
		votes.map{
			$0.rankings.map(\.name)
		}
	}
}


extension AltVote{
	//Format: https://github.com/vstenby/AlternativeVote/blob/main/KABSDemo.csv
	public func toCSV() -> String {
		
		var csv = "Tidsstempel,Studienummer"
		
		let allOptionsSortedByName = options.sorted(by: {$0.name < $1.name})
		for i in allOptionsSortedByName {
			csv += ",Stemmeseddel [\(i.name)]"
		}
		
		
		for voter in votes{
			csv += "\n 01/01/2001 00.00.01, \(voter.user.identifier)"
			
			var obj = [String: Int]()
			for j in 0..<voter.rankings.count{
				obj[voter.rankings[j].name] = j + 1
			}
			
			for i in allOptionsSortedByName{
				if let priority = obj[i.name]{
					csv += ",\(priority).0"
				} else {
					csv += ","
				}
			}
			
		}
		
		return csv
	}

	public func constituentsToCSV() -> String{
		var csv = "Navn,Studienummer"

		for voter in self.eligibleVoters{
			csv += "\n"
			
			let name = voter.name ?? voter.identifier
			csv += "\(name), \(voter.identifier)"
		}
		return csv
	}
}
