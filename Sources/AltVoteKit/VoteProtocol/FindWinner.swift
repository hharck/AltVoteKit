extension AltVote{
	public func findWinner(force: Bool) async throws -> [VoteOption]?{
		var winner: [AltVoteKit.VoteOption]? = nil
		
		var excluded = Set<VoteOption>()
		let allOptions = Set(options)
		
		var lastCount: [VoteOption: UInt]? = nil
		
		while winner == nil{
			if excluded == allOptions{
				return nil
			}
			
			
			lastCount = try await count(force: excluded.isEmpty ? force : true, excluding: Array(excluded))
			
			let sortedList = lastCount!
				.map{ key, value in
					(votes: value, option: key)
				}
				.sorted{ first, second in
					if first.votes == second.votes{
						return first.option.name < second.option.name
					} else {
						return first.votes > second.votes
					}
				}
			/// Sum of all votes
			let totalVotes = lastCount!.map(\.value).reduce(0, +)
			
			//Checks for edge cases
			if sortedList.count == 0 {
				return nil
			} else if sortedList.count == 1{
				winner = [sortedList.first!.option]
				continue
			} else if totalVotes / 2 + 1 <= sortedList.first!.votes{
				winner = [sortedList.first!.option]
				continue
			} else {
				// The minimum number of votes a given option has
				let lowestVoteCount = sortedList.last!.votes
				
				// All the options tied for last
				var bottom: [AltVoteKit.VoteOption] = []
				for i in sortedList.reversed() {
					if i.votes != lowestVoteCount {
						break
					} else {
						bottom.append(i.option)
					}
				}
				
				if bottom.count == sortedList.count{
					winner = bottom
					continue
				} else if bottom.count == 1{
					excluded.insert(sortedList.last!.option)
					continue
				} else {
					// Applies TieBreakers
					for tieBreaker in tieBreakingRules{
						guard let tb = (tieBreaker as? normalTieBreakable) else{
							continue
						}
						let tbResult = tb.breakTie(votes: votes, options: options, optionsLeft: allOptions.subtracting(excluded).count)
						
						let toRemove = tbResult.compactMap{ res -> AltVoteKit.VoteOption? in
							if res.value == .remove{
								return res.key
							} else{
								return nil
							}
						}

						if toRemove.isEmpty{
							continue
						} else {
							excluded.formUnion(toRemove)
							break
						}
					}
				}
			}
		}
		return winner
	}
}




