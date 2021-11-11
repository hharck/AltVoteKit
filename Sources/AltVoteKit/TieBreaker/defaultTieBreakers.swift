extension TieBreakable{
	
	/// Removes a random option
	public static var removeRandom: TieBreaker {
		TieBreaker(name: "Remove random", id: "removeRandom") { _, options, _  in
			var dict = options.reduce(into: [Option: TieBreak]()) {
				$0[$1] = TieBreak.keep
			}
			
			dict[dict.keys.randomElement()!] = TieBreak.remove
			return dict
		}
	}
	/// Keeps a random option
	public static var keepRandom: TieBreaker {
		TieBreaker(name: "Keep random", id: "keepRandom") { _, options, _  in
			var dict = options.reduce(into: [Option: TieBreak]()) {
				$0[$1] = TieBreak.remove
			}
			dict[dict.keys.randomElement()!] = TieBreak.keep
			return dict
		}
	}
	
	
	/// Removes everyone that's tied, unless it's every option that's tied
	public static var dropAll: TieBreaker {
		TieBreaker(name: "Drop all unless they're last", id: "dropAll") { _, options, numberLeft in
			guard numberLeft != options.count else {
				return options.reduce(into: [Option: TieBreak]()) {
					//Keeps all
					$0[$1] = TieBreak.keep
				}
			}
			
			return options.reduce(into: [Option: TieBreak]()) {
				$0[$1] = TieBreak.remove
			}
			
		}
	}
	public static var allTieBreakers: [TieBreakable] {[removeRandom, keepRandom, dropAll]}
}
