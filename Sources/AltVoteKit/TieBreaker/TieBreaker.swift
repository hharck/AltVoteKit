public struct TieBreaker: normalTieBreakable{
	internal init(name: String, id: String, closure: @escaping ([SingleVote], [Option], Int) -> [Option : TieBreak]) {
		self.name = name
		self.id = id
		self.closure = closure
	}
	
	
	/// The name of the TieBreaker
	public let name: String
	
	/// The id of the TieBreaker
	public let id: String
	
	/// Returns every vote in violation of the validator
	private var closure: (_ votes: [SingleVote], _ options: [Option], _ optionsLeft: Int) -> [Option : TieBreak]
	
	
	/// Run the tie breaker
	/// - Parameters:
	///   - votes: The votes cast
	///   - options: The options that are in a tie
	///   - optionsLeft: The total number of options left
	/// - Returns: Options and their status
	public func breakTie(votes: [SingleVote], options: [Option], optionsLeft: Int) -> [Option : TieBreak] {
		assert(options.count <= optionsLeft)
		if options.isEmpty{
			return [:]
		} else {
			let result = closure(votes, options, optionsLeft)
			assert(Set(result.keys) == Set(options), "Tie breaker not returning a value for every option")
			return result
		}
	}
}

/*
 A piece of code usable for getting all priorities and such
 
 
 var d = [Int: Int]()
 //Sets all votes to zero
 for i in 1...options.count{
 d[i] = 0
 }
 
 // Creates a list of options and the number of votes on each priority
 // 		[voting option: [the rank : number of votes for this rank]
 var priorites: [Option: [Int:Int]] = options.reduce(into: [Option: [Int:Int]]()) { partialResult, option in
 partialResult[option] = d
 }
 
 votes.forEach { vote in
 assert(vote.rankings.count <= options.count)
 for i in 0..<vote.rankings.count{
 let option = vote.rankings[i]
 priorites[option]![i+1]! += 1
 }
 }
 
 return priorites
 */
