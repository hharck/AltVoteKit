import Foundation
public typealias UserID = String

public protocol AltVote: Actor, Hashable{
	func validate() -> [ValidationResult]
	func count(force: Bool, excluding: [Option]) async throws -> [Option: UInt]
	
	/// A unique identifier for the vote
	var id: UUID {get}
	
	/// Name of the vote
	var name: String {get}
	
	/// The options available in this vote
	var options: [Option] {get set}
	
	/// The votes cast
	var votes: [SingleVote] {get set}
	
	/// Definitions for what makes a vote valid
	var validators: [Validateable] {get set}
	
	/// A set of users who are expected to vote
	var eligibleVoters: Set<UserID> {get set}
	
	/// Rules for breaking a tie, applied in the order given.
	var tieBreakingRules: [TieBreakable] {get set}
	
	/// Extra data set by the client
	var customData: [String: String] {get set}

	
	init(id: UUID, name: String, options: [Option], votes: [SingleVote], validators: [Validateable], eligibleVoters: Set<UserID>, tieBreakingRules: [TieBreakable])
}
