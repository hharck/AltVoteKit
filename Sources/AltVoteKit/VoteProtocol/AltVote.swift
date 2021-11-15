import Foundation

public protocol AltVote: Actor, Hashable{
	func validate() -> [VoteValidationResult]
	func count(force: Bool, excluding: [VoteOption]) async throws -> [VoteOption: UInt]
	
	/// A unique identifier for the vote
	var id: UUID {get}
	
	/// Name of the vote
	var name: String {get}
	
	/// The options available in this vote
	var options: [VoteOption] {get set}
	
	/// The votes cast
	var votes: [SingleVote] {get set}
	
	/// Definitions for what makes a vote valid
	var validators: [Validateable] {get set}
	
	/// A set of users who are expected to vote
	var eligibleVoters: Set<Constituent> {get set}
	
	/// Rules for breaking a tie, applied in the order given.
	var tieBreakingRules: [TieBreakable] {get set}
	
	/// Extra data set by the client
	var customData: [String: String] {get set}

	
	init(id: UUID, name: String, options: [VoteOption], votes: [SingleVote], validators: [Validateable], eligibleVoters: Set<Constituent>, tieBreakingRules: [TieBreakable])
}
