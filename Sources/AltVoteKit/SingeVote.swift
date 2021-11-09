/// Defines the vote of a single person
public struct SingleVote: Hashable, Codable{
	var userID: UserID
	
	var rankings: [Option]
	
	init(_ userID: UserID, rankings: [Option]){
		self.userID = userID
		self.rankings = rankings
	}
	
	internal init(bareBonesVote id: UserID){
		userID = id
		rankings = []
	}
}
