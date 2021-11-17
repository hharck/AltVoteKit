extension AltVote{
	public func findWinner(force: Bool, excluding: Set<VoteOption> = []) async throws -> [VoteOption]{
		var winner: [VoteOption]? = nil
		
		var excluded = excluding
		let allOptions = Set(options)
		
		/// How many votes each option has in the current round
		var lastCount: [VoteOption: UInt]? = nil
		
		//Runs untill a winner has been found
		while winner == nil{
			if excluded == allOptions{
				winner = []
			}
			
			//Counts the number of highest priority votes for each option
			lastCount = try await count(force: excluded.isEmpty ? force : true, excluding: Array(excluded))
			
			//Converts the counted votes into a tuple of number of votes and the option
			let sortedList = lastCount!
				.map{ key, value in
					(votes: value, option: key)
				}
			// Sorts by number of votes (or name if no. of votes are equal)
				.sorted{ first, second in
					if first.votes == second.votes{
						return first.option.name < second.option.name
					} else {
						return first.votes > second.votes
					}
				}
			
			/// The number of non blank votes cast in the last round
			let totalVoteCount = lastCount!.map(\.value).reduce(0, +)
			
			//Checks for edge cases
			if sortedList.count == 0 {
				//Shouldn't happen
				assertionFailure()
				winner = []
			} else if sortedList.count == 1{
				//If only a single candidate is left, he/she must be the winner
				winner = [sortedList.first!.option]
				continue
			} else if totalVoteCount / 2 + 1 <= sortedList.first!.votes{
				//>50% on a single option
				winner = [sortedList.first!.option]
				continue
			} else {
				// The number of votes the least favorable option has
				let lowestVoteCount = sortedList.last!.votes
				
				// All the options tied for last
				// Goes through the list of options from fewest votes to most votes
				var bottom: [VoteOption] = []
				for i in sortedList.reversed() {
					if i.votes != lowestVoteCount {
						break
					} else {
						bottom.append(i.option)
					}
				}
				
				// Checks if everyone is tied
				if bottom.count == sortedList.count{
					winner = bottom
					continue
				} else if bottom.count == 1{
					//If only a single option has the lowest amount of votes, it will be excluded
					excluded.insert(sortedList.last!.option)
					continue
				} else {
					// Applies TieBreakers
					for tieBreaker in tieBreakingRules{
						guard let tb = (tieBreaker as? normalTieBreakable) else{
							continue
						}
						
						let tbResult = tb.breakTie(votes: votes, options: bottom, optionsLeft: allOptions.subtracting(excluded).count)
						
						let toRemove = tbResult.compactMap{ res -> VoteOption? in
							if res.value == .remove{
								return res.key
							} else{
								return nil
							}
						}
						
						// Removes every option the tiebreaker marked with ".remove", if none was marked, it'll continue on to the next TieBreaker
						if toRemove.isEmpty{
							if tieBreaker.id == self.tieBreakingRules.last?.id{
								throw TieBreaker.TieBreakingError.noTBwasAbleToBreakTie
							}
							continue
						} else {
							excluded.formUnion(toRemove)
							break
						}
					}
				}
			}
		}
		return winner!
	}
}




