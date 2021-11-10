public actor Vote: AltVote{
	public init(options: [Option], votes: [SingleVote], validators: [Validateable], eligibleUsers: Set<UserID>, tieBreakingRules: [TieBreakable]) {
		self.options = options
		self.votes = votes
		self.validators = validators
		self.eligibleUsers = eligibleUsers
		self.tieBreakingRules = tieBreakingRules
	}
	
	var options: [Option]
	var votes: [SingleVote]
	var validators: [Validateable]
	var eligibleUsers: Set<UserID>
	var tieBreakingRules: [TieBreakable]
}
