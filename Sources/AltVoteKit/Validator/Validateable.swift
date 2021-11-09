protocol Validateable{
	func validate(_ votes: [SingleVote], _ eligibleUsers: Set<UserID>, allOptions: [Option]) -> ValidationResult
}
