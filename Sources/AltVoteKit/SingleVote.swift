/// Defines the vote of a single person
public struct SingleVote: Sendable, Hashable, Codable{
	public var userID: Constituent
	
	public var rankings: [VoteOption]
	
	public init(_ userID: Constituent, rankings: [VoteOption]){
		self.userID = userID
		self.rankings = rankings
	}
	
	/// Used for creating a user that hasn't voted
	internal init(bareBonesVote id: Constituent){
		userID = id
		rankings = []
	}
}
