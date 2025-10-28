import VoteKit

public protocol AlternativeVoteError: Error {}
extension TieBreaker.TieBreakingError: AlternativeVoteError {}
extension VoteKitValidationErrors: AlternativeVoteError {}
