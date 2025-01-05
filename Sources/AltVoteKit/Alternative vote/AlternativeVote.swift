import Foundation
import VoteKit
/// Defines a vote of the "Alternative vote" kind
public actor AlternativeVote: SingleWinnerVote, HasCustomValidators {
    public var id: UUID
    public var name: String
    public var options: [VoteOption]
    public var votes: [SingleVote]
    public var genericValidators: [GenericValidator<SingleVote>]
    public var constituents: Set<Constituent>
    // FIXME: This is a constant as a workaround for https://github.com/swiftlang/swift/issues/78442 which occurs in `VoteProtocol.validate`
    public let customValidators: [AlternativeVoteValidator]
    public var tieBreakingRules: [TieBreakable]
    
    public static let typeName: String = "Alternative vote"
    
	public init(options: [VoteOption], constituents: Set<Constituent>, votes: [SingleVote]) {
		self.votes = votes
		self.options = options
		self.constituents = constituents
		
		self.id = UUID()
		self.name = "Imported vote"
		self.genericValidators = []
        self.customValidators = []
		
		self.tieBreakingRules = [TieBreaker.dropAll, TieBreaker.removeRandom, TieBreaker.keepRandom]
	}
	
	
	public init(id: UUID = UUID(), name: String, options: [VoteOption], votes: [SingleVote] = [], constituents: Set<Constituent>, tieBreakingRules: [TieBreakable], genericValidators: [GenericValidator<SingleVote>], customValidators: [AlternativeVoteValidator]) {
		self.id = id
		self.name = name
		self.votes = votes
		self.options = options
		self.constituents = constituents
		self.tieBreakingRules = tieBreakingRules
		self.genericValidators = genericValidators
        self.customValidators = customValidators
	}
}

// MARK: Required methods
extension AlternativeVote{
    public func count(force: Bool) async throws -> [VoteOption : UInt] {
		try await count(force: force, excluding: [])
	}
}
