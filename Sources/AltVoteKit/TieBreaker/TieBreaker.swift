import VoteKit

public enum TieBreaker: String, Codable, CaseIterable {
	case removeRandom, keepRandom, dropAll
}

extension TieBreaker: NormalTieBreakable {
	public func breakTie(votes: [SingleVote], options: [VoteOption], optionsLeft: Int) -> [VoteOption: TieBreak] {
		assert(options.count <= optionsLeft)
		if options.isEmpty {
			return [:]
		} else {
			let result: [VoteOption: TieBreak]
			switch self {
			case .removeRandom:
				result = removeRandom(votes: votes, options: options, optionsLeft: optionsLeft)
			case .keepRandom:
				result = keepRandom(votes: votes, options: options, optionsLeft: optionsLeft)
			case .dropAll:
				result = dropAll(votes: votes, options: options, optionsLeft: optionsLeft)

			}
			assert(Set(result.keys) == Set(options), "Tiebreaker not returning a value for every option")
			return result
		}
	}

	public var name: String {
		switch self {
		case .removeRandom:
			return "Remove random"
		case .keepRandom:
			return "Keep random"
		case .dropAll:
			return "Drop all unless all are tied"
		}
	}

	public var id: String {
		self.rawValue
	}

	// MARK: Tiebreakers
	/// Removes a random option
	public func removeRandom(votes: [SingleVote], options: [VoteOption], optionsLeft: Int) -> [VoteOption: TieBreak] {
		var dict = options.reduce(into: [VoteOption: TieBreak]()) {
			$0[$1] = TieBreak.keep
		}

		dict[dict.keys.randomElement()!] = TieBreak.remove
		return dict
	}

	/// Keeps a random option
	public func keepRandom(votes: [SingleVote], options: [VoteOption], optionsLeft: Int) -> [VoteOption: TieBreak] {
		var dict = options.reduce(into: [VoteOption: TieBreak]()) {
			$0[$1] = TieBreak.remove
		}
		dict[dict.keys.randomElement()!] = TieBreak.keep
		return dict
	}

	/// Removes everyone that's tied, unless it's every option that's tied
	public func dropAll(votes: [SingleVote], options: [VoteOption], optionsLeft: Int) -> [VoteOption: TieBreak] {
		guard optionsLeft != options.count else {
			return options.reduce(into: [VoteOption: TieBreak]()) {
				// Keeps all
				$0[$1] = TieBreak.keep
			}
		}

		return options.reduce(into: [VoteOption: TieBreak]()) {
			$0[$1] = TieBreak.remove
		}
	}

	public enum TieBreakingError: Error {
		case noTBwasAbleToBreakTie
	}
}
