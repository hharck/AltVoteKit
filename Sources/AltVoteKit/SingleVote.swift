/// Defines the vote of a single person
public struct SingleVote: Sendable, Hashable, Codable{
	public var user: Constituent
	
	public var rankings: [VoteOption]
	
	public init(_ user: Constituent, rankings: [VoteOption]){
		self.user = user
		self.rankings = rankings
	}
	
	/// Used for creating a user that hasn't voted
	internal init(bareBonesVote id: Constituent){
		user = id
		rankings = []
	}
}
