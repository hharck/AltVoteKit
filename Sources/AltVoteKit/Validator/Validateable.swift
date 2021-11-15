public protocol Validateable: Sendable{
	func validate(_ votes: [SingleVote], _ eligibleUsers: Set<UserID>, allOptions: [VoteOption]) -> VoteValidationResult
	
	/// The id of the validator
	var id: String {get}
	
	/// A name for use in UI
	var name: String {get}
}
