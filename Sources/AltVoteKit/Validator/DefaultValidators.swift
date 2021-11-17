extension Validateable{
	/// Will not validate any user voting multiple times
	internal static var oneVotePerUser: VoteValidator {
		VoteValidator(id: "OneVotePerUser", name: "One vote per. user", offenseText: {"\($0.user.identifier) voted multiple times"}) { votes, _  in
			
			var allUnique = [Constituent]()
			let allOffendingIDs = votes.compactMap{ vote -> SingleVote? in
				if allUnique.contains(vote.user){
					return vote
				} else {
					allUnique.append(vote.user)
					return nil
				}
			}
			
			return allOffendingIDs
		}
	}
	
	/// Will not validate untill everyone on the allowed voters list has votes
	public static var everyoneHasVoted: VoteValidator {
		VoteValidator(id: "EveryoneVoted", name: "All verified users are required to vote", offenseText: {"\($0.user.identifier) hasn't voted"}) { votes, eligibleUsers in
			let userIDs = votes.map(\.user)
			let offenders = eligibleUsers.compactMap{ user -> SingleVote? in
				if userIDs.contains(user){
					return nil
				} else {
					return SingleVote(bareBonesVote: user)
				}
			}
			
			return offenders
		}
	}
	
	/// Will not validate if a user not on the allowed users list has voted
	public static var onlyVerifiedVotes: VoteValidator {
		VoteValidator(id: "onlyVerifiedVotes", name: "Only verified votes", offenseText: {"\($0.user.identifier) has voted even though they aren't on the list of verified users"}) { votes, eligibleUsers in
			
			return votes.compactMap { vote in
				if eligibleUsers.contains(vote.user){
					return nil
				} else {
					return vote
				}
			}
		}
	}
	
	/// A vote should contain a priority for all candidates
	public static var preferenceForAllCandidates: VoteValidator {
		VoteValidator(id: "AllCandidatesRequiresAaVote", name: "All candidates requires a vote", offenseText: {"\($0.user) hasn't voted for all candidates"}) {
			votes, _, options in
			
			return options.flatMap { option in
				votes.filter { vote in
					!vote.rankings.contains(option)
				}
			}
		}
	}
	
	/// All votes should be for atleast one of the options
	public static var noBlankVotes: VoteValidator {
		VoteValidator(id: "NoBlanks", name: "No blank votes", offenseText: {"\($0.user) voted blank"}) { votes, _ in
			votes.filter {$0.rankings.isEmpty}
		}
	}
	public static var defaultValidators: [Validateable] {[everyoneHasVoted, onlyVerifiedVotes, preferenceForAllCandidates, noBlankVotes]}
}
