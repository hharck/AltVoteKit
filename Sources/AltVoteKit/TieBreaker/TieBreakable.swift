public protocol TieBreakable{
		
}

public protocol normalTieBreakable{
	func breakTie(votes: [SingleVote], options: [Option], optionsLeft: Int) -> [Option : TieBreak]
}

public enum TieBreak{
	case remove, keep
}
