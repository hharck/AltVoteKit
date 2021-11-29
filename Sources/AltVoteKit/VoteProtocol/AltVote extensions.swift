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
			validator.validate(votes, constituents, allOptions: options)
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
			//If all votes have been excluded this vote will not be put into 'excludingVotes'
			guard !vote.rankings.isEmpty else {
				return nil
			}
			return vote
		}
		
		//Sets zero votes cast for all, allowed, options
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
		guard votes.map(\.constituent.identifier).nonUniques.isEmpty else {
			return false
		}
		
		self.votes = votes
		return true
	}
	
	/// Adds a vote to the list of votes
	/// - Parameter vote: The vote to set
	/// - Returns: Whether all userIDs were unique
	@discardableResult public func addVote(_ vote: SingleVote) -> Bool{
		if hasConstituentVoted(vote.constituent){
			return false
		}
		
		self.votes.append(vote)
		return true
	}
	
	public func resetVoteForUser(_ user: Constituent){
		resetVoteForUser(user.identifier)
	}
	
	public func resetVoteForUser(_ id: ConstituentID){
		self.votes.removeAll(where: {vote in
			vote.constituent.identifier == id
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
	/// Sets the constituents property, overriding any existing information
	public func setConstituents(_ voters: Set<Constituent>) async{
		self.constituents = voters
	}
	
	/// Adds a constituents and replaced any former ghosts if they exists
	public func addConstituents(_ voter: Constituent) async{
		if let dobbelganger = self.constituents.first(where: {$0.identifier == voter.identifier}){
			self.constituents.remove(dobbelganger)
		}
		
		self.constituents.insert(voter)
	}
	
	/// Adds multiple  constituents
	public func addConstituents(_ constituents: Set<Constituent>) async{
		self.constituents.formUnion(constituents)
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
	
	/// Retrieves an array of options
	public func getAllOptions() async -> [VoteOption]{
		self.options
	}
	
	/// Checks if a given constituent already has voted in this vote
	public func hasConstituentVoted(_ user: Constituent) -> Bool{
		hasConstituentVoted(user.identifier)
	}
	
	/// Checks if a given constituentID already has voted in this vote
	public func hasConstituentVoted(_ identifier: ConstituentID) -> Bool{
		self.votes.contains(where: {
			$0.constituent.identifier == identifier
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

// CSV export
extension AltVote{
	//Format: https://github.com/vstenby/AlternativeVote/blob/main/KABSDemo.csv
	public func toCSV() -> String {
		
		var csv = "Tidsstempel,Studienummer"
		
		let allOptionsSortedByName = options.sorted(by: {$0.name < $1.name})
		for i in allOptionsSortedByName {
			csv += ",Stemmeseddel [\(i.name)]"
		}
		
		
		for voter in votes{
			csv += "\n 01/01/2001 00.00.01, \(voter.constituent.identifier)"
			
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

	public static func constituentsToCSV(_ voters: Set<Constituent>) -> String{
		var csv = "Navn,Studienummer"
		
		let voters = Array(voters).sorted { $0.identifier < $1.identifier}
		
		for voter in voters {
			csv += "\n"
			
			let name = voter.name ?? voter.identifier
			csv += "\(name),\(voter.identifier)"
		}
		return csv
	}
}
