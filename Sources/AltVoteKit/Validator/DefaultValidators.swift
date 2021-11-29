extension Validateable{
	/// Will not validate any constitutent voting multiple times
	internal static var oneVotePerUser: VoteValidator {
		VoteValidator(id: "OneVotePerUser", name: "One vote per. user", offenseText: {"\($0.constituent.identifier) voted multiple times"}) { votes, _  in
			
			var allUnique = [Constituent]()
			let allOffendingIDs = votes.compactMap{ vote -> SingleVote? in
				if allUnique.contains(vote.constituent){
					return vote
				} else {
					allUnique.append(vote.constituent)
					return nil
				}
			}
			
			return allOffendingIDs
		}
	}
	
	/// Will not validate untill everyone on the allowed voters list has votes
	public static var everyoneHasVoted: VoteValidator {
		VoteValidator(id: "EveryoneVoted", name: "All verified users are required to vote", offenseText: {"\($0.constituent.identifier) hasn't voted"}) { votes, constituents in
			let voters = votes.map(\.constituent)
			let offenders = constituents.compactMap{ const -> SingleVote? in
				if voters.contains(const){
					return nil
				} else {
					return SingleVote(bareBonesVote: const)
				}
			}
			
			return offenders
		}
	}
	
	/// Will not validate if a constituent who is not on the allowed users list has voted
	public static var onlyVerifiedVotes: VoteValidator {
		VoteValidator(id: "onlyVerifiedVotes", name: "Only verified votes", offenseText: {"\($0.constituent.identifier) has voted even though they aren't on the list of verified users"}) { votes, constituents in
			
			return votes.compactMap { vote in
				if constituents.contains(vote.constituent){
					return nil
				} else {
					return vote
				}
			}
		}
	}
	
	/// A vote should contain a priority for all candidates
	public static var preferenceForAllCandidates: VoteValidator {
		VoteValidator(id: "AllCandidatesRequiresAaVote", name: "All candidates requires a vote", offenseText: {"\($0.constituent) hasn't voted for all candidates"}) {
			votes, _, options in
			// Filters all users who hasn't voted for all available options
			return votes.filter{ vote in
				// Checks for unexpected values and stops execution on debug builds
				assert(options.count >= vote.rankings.count, "Voter has voted for options than available\nVoted for: \(vote.rankings.map(\.name))\nAvailable\(options.map(\.name))")
				
				/* One liner for the code below:
				 //return !(options.count == $0.rankings.count || $0.rankings.isEmpty)
				 */
				
				// Checks if the constituent has voted for all options
				if options.count == vote.rankings.count{
					return false
				} else if vote.rankings.isEmpty {
					//It's a blank vote then, which is handled by the 'noBlankVotes' validator
					return false
				} else {
					return true
				}
			}
			
		}
	}
	
	/// All votes should be for atleast one of the options
	public static var noBlankVotes: VoteValidator {
		VoteValidator(id: "NoBlanks", name: "No blank votes", offenseText: {"\($0.constituent) voted blank"}) { votes, _ in
			votes.filter {$0.rankings.isEmpty}
		}
	}
	
	/// Defines an Array of all validators
	public static var defaultValidators: [Validateable] {[everyoneHasVoted, onlyVerifiedVotes, preferenceForAllCandidates, noBlankVotes]}
}
