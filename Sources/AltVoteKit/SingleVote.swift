/// Defines the vote of a single person
public struct SingleVote: Sendable, Hashable, Codable{
	public var constituent: Constituent
	
	public var rankings: [VoteOption]
	
	public init(_ constituent: Constituent, rankings: [VoteOption]){
		self.constituent = constituent
		self.rankings = rankings
	}
	
	/// Used for creating a constituent that hasn't voted
	internal init(bareBonesVote id: Constituent){
		constituent = id
		rankings = []
	}
}
