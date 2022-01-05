import VoteKit

public enum AlternativeVoteValidator: String, Codable, CaseIterable{
	case allCandidatesRequiresAaVote
}

extension AlternativeVoteValidator: Validateable{
	public static var allValidators: [AlternativeVoteValidator] {
		Array(self.allCases)
	}
	
	public func validate(_ votes: [SingleVote], _ constituents: Set<Constituent>, _ allOptions: [VoteOption]) -> VoteValidationResult {
		switch self {
		case .allCandidatesRequiresAaVote:
			return validateAllCandidatesRequiresAaVote(votes, constituents, allOptions)
		}
	}
	
	func validateAllCandidatesRequiresAaVote(_ votes: [SingleVote], _ constituents: Set<Constituent>, _ allOptions: [VoteOption]) -> VoteValidationResult {
		// Filters all users who hasn't voted for all available options
		let errors = votes
			.filter{ vote in
				// Checks for unexpected values and stops execution on debug builds
				assert(allOptions.count >= vote.rankings.count, "Constituent has voted for more options than those available\nVoted for: \(vote.rankings.map(\.name))\nAvailable: \(allOptions.map(\.name))")
				
				/* One liner for the code below:
				 //return !(options.count == $0.rankings.count || $0.rankings.isEmpty)
				 */
				
				// Checks if the constituent has voted for all options
				if allOptions.count == vote.rankings.count{
					return false
				} else if vote.rankings.isEmpty {
					//It's a blank vote then, which is handled by the 'noBlankVotes' validator
					return false
				} else {
					return true
				}
			}
			.map { vote in
				"\(vote.constituent.identifier) hasn't voted for all candidates"
			}
		
		return VoteValidationResult(name: self.name, errors: errors)
	}
	
	
	public var id: String {
		return self.rawValue
	}
	
	public var name: String{
		switch self {
		case .allCandidatesRequiresAaVote:
			return "All candidates requires a vote"
		}
	}
	
}
