import Foundation
public actor Vote: AltVote{
	public var id: UUID = UUID()
	
	public init(options: [Option], votes: [SingleVote], validators: [Validateable], eligibleVoters: Set<UserID>, tieBreakingRules: [TieBreakable]) {
		self.options = options
		self.votes = votes
		self.validators = validators
		self.eligibleVoters = eligibleVoters
		self.tieBreakingRules = tieBreakingRules
	}
	
	public var options: [Option]
	public var votes: [SingleVote]
	public var validators: [Validateable]
	public var eligibleVoters: Set<UserID>
	public var tieBreakingRules: [TieBreakable]
}
