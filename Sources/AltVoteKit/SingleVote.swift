/// Defines the vote of a single person
public struct SingleVote: Sendable, Hashable, Codable{
	public var userID: UserID
	
	public var rankings: [Option]
	
	public init(_ userID: UserID, rankings: [Option]){
		self.userID = userID
		self.rankings = rankings
	}
	
	/// Used for creating a user that hasn't voted
	internal init(bareBonesVote id: UserID){
		userID = id
		rankings = []
	}
}
