public protocol Validateable: Sendable{
	func validate(_ votes: [SingleVote], _ constituents: Set<Constituent>, allOptions: [VoteOption]) -> VoteValidationResult
	
	/// The id of the validator
	var id: String {get}
	
	/// A name for use in UI
	var name: String {get}
}
