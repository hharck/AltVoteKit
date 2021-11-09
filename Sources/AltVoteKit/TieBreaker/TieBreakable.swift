protocol TieBreakable{
		
}

protocol normalTieBreakable{
	func breakTie(votes: [SingleVote], options: [Option], optionsLeft: Int) -> [Option : TieBreak]
}

enum TieBreak{
	case remove, keep
}
