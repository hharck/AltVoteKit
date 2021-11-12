import Foundation
public actor Vote: AltVote{
	
	public init(id: UUID, name: String, options: [Option], votes: [SingleVote], validators: [Validateable], eligibleVoters: Set<UserID>, tieBreakingRules: [TieBreakable]) {
		self.id = id
		self.name = name
		self.options = options
		self.votes = votes
		self.validators = validators
		self.eligibleVoters = eligibleVoters
		self.tieBreakingRules = tieBreakingRules
	}
	
	public let id: UUID
	public let name: String
	public var options: [Option]
	public var votes: [SingleVote]
	public var validators: [Validateable]
	public var eligibleVoters: Set<UserID>
	public var tieBreakingRules: [TieBreakable]
}
