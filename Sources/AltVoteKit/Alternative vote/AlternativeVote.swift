import Foundation
import VoteKit
/// Defines a vote of the "Alternative vote" kind
public actor AlternativeVote: SingleWinnerVote{
    public var id: UUID
    public var name: String
    public var options: [VoteOption]
    public var votes: [SingleVote]
    public var genericValidators: [GenericValidator<SingleVote>] = []
    public var constituents: Set<Constituent>
    public var customData: [String : String] = [:]
    public var particularValidators: [AlternativeVoteValidator] = []
    public var tieBreakingRules: [TieBreakable]
    
    public static let typeName: String = "Alternative vote"
    
	public init(options: [VoteOption], constituents: Set<Constituent>, votes: [SingleVote]) {
		self.votes = votes
		self.options = options
		self.constituents = constituents
		
		self.id = UUID()
		self.name = "Imported vote"
		self.genericValidators = []
		
		self.tieBreakingRules = [TieBreaker.dropAll, TieBreaker.removeRandom, TieBreaker.keepRandom]
	}
	
	
	public init(id: UUID = UUID(), name: String, options: [VoteOption], votes: [SingleVote] = [], constituents: Set<Constituent>, tieBreakingRules: [TieBreakable], genericValidators: [GenericValidator<SingleVote>], particularValidators: [AlternativeVoteValidator]) {
		self.id = id
		self.name = name
		self.votes = votes
		self.options = options
		self.particularValidators = particularValidators
		self.constituents = constituents
		self.tieBreakingRules = tieBreakingRules
		self.genericValidators = genericValidators
	}
}

// MARK: Required methods
extension AlternativeVote{
    public func count(force: Bool) async throws -> [VoteOption : UInt] {
		try await count(force: force, excluding: [])
	}
}
