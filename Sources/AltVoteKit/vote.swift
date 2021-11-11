public actor Vote: AltVote{
	public init(options: [Option], votes: [SingleVote], validators: [Validateable], eligibleVoters: Set<UserID>, tieBreakingRules: [TieBreakable]) {
		self.options = options
		self.votes = votes
		self.validators = validators
		self.eligibleVoters = eligibleVoters
		self.tieBreakingRules = tieBreakingRules
	}
	
	var options: [Option]
	var votes: [SingleVote]
	var validators: [Validateable]
	var eligibleVoters: Set<UserID>
	var tieBreakingRules: [TieBreakable]
}
