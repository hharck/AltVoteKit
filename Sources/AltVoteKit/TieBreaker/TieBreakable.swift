public protocol TieBreakable{
	
	/// The name of the TieBreaker
	var name: String {get}
	
	/// The id of the TieBreaker
	var id: String {get}
}

public protocol normalTieBreakable{
	func breakTie(votes: [SingleVote], options: [Option], optionsLeft: Int) -> [Option : TieBreak]
}

public enum TieBreak{
	case remove, keep
}
