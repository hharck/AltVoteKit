extension Validator{
	/// Will not validate any user voting multiple times
	public static let oneVotePerUser = Validator(id: "OneVotePerUser", name: "One vote per. user", offenseText: {"\($0.userID) voted multiple times"}) { votes, _  in
		
		var allUnique = [UserID]()
		let allOffendingIDs = votes.compactMap{ vote -> SingleVote? in
			if allUnique.contains(vote.userID){
				return vote
			} else {
				allUnique.append(vote.userID)
				return nil
			}
		}
		
		return allOffendingIDs
	}
	
	/// Will not validate untill everyone on the allowed voters list has votes
	public static let everyoneHasVoted = Validator(id: "EveryoneVoted", name: "Everyone has voted", offenseText: {"\($0.userID) hasn't voted"}) { votes, eligibleUsers in
		let userIDs = votes.map(\.userID)
		let offenders = eligibleUsers.compactMap{ user -> SingleVote? in
			if userIDs.contains(user){
				return nil
			} else {
				return SingleVote(bareBonesVote: user)
			}
		}
		
		return offenders
	}
	
	/// Will not validate if a user not on the allowed users list has voted
	public static let noForeignVotes = Validator(id: "NoForeignVotes", name: "No foreign votes", offenseText: {"\($0.userID) has voted enough they aren't on the list of allowed users"}) { votes, eligibleUsers in
		
		return votes.compactMap { vote in
			if eligibleUsers.contains(vote.userID){
				return nil
			} else {
				return vote
			}
		}
	}
	
	/// A vote should contain a priority for all candidates
	public static let preferenceForAllCandidates = Validator(id: "AllCandidatesRequiresAaVote", name: "All candidates requires a vote", offenseText: {"\($0.userID) hasn't voted for all candidates"}) {
		votes, _, options in
		
		return options.flatMap { option in
			votes.filter { vote in
				!vote.rankings.contains(option)
			}
		}
	}
	
	/// All votes should be for atleast one of the options
	public static let noBlankVotes = Validator(id: "NoBlanks", name: "No blank votes", offenseText: {"\($0.userID) voted blank"}) { votes, _ in
		votes.filter {$0.rankings.isEmpty}
	}
}
