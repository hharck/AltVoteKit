import Foundation
public actor Vote: AltVote{
	public init(id: UUID = UUID(), name: String, options: [VoteOption], votes: [SingleVote], validators: [Validateable], constituents: Set<Constituent>, tieBreakingRules: [TieBreakable]) {
		self.id = id
		self.name = name
		self.options = options
		self.votes = votes
		self.validators = validators
		self.constituents = constituents
		self.tieBreakingRules = tieBreakingRules
	}
	
	public let id: UUID
	public let name: String
	public var options: [VoteOption]
	public var votes: [SingleVote]
	public var validators: [Validateable]
	public var constituents: Set<Constituent>
	public var tieBreakingRules: [TieBreakable]
	public var customData: [String : String] = [:]

}
