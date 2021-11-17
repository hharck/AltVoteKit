import XCTest
@testable import AltVoteKit

final class AltVoteKitTests: XCTestCase {
    func testExample() async throws {
		let opt: [VoteOption] = ["Person 1", "Person 2", "Person 3"]
		
		let voterHans = Constituent(identifier: "Hans")
		let voterSofus = Constituent(identifier: "Sofus")
		
		let vote = Vote(id: UUID(), name: "", options: opt, votes: [SingleVote(voterHans, rankings: opt.reversed())], validators: VoteValidator.defaultValidators, eligibleVoters: [voterHans], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.keepRandom])
		
		let countAll = try await vote.count()
		let countWo0 = try await vote.count(force: false, excluding: [opt[0]])
		let countWo2 = try await vote.count(force: false, excluding: [opt[2]])
		
		print(countAll)
		
		XCTAssertEqual([
			opt[0]:0,
			opt[1]:0,
			opt[2]:1
		], countAll)
		

		XCTAssertEqual([
			opt[1]:0,
			opt[2]:1
		], countWo0)

		XCTAssertNotEqual([
			opt[0]:0,
			opt[1]:0,
			opt[2]:1
		], countWo0)
		
		XCTAssertEqual([
			opt[0]:0,
			opt[1]:1
		], countWo2)

		
		//And now with Sofus
		await vote.addEligigbleVoters(voterSofus)
		await vote.addVotes(SingleVote(voterSofus, rankings: opt))
		
		let countAllWS = try await vote.count()
		let countWo0WS = try await vote.count(force: false, excluding: [opt[0]])
		let countWo2WS = try await vote.count(force: false, excluding: [opt[2]])
		let countWo02WS = try await vote.count(force: false, excluding: [opt[0], opt[2]])

		
		XCTAssertEqual([
			opt[0]:1,
			opt[1]:0,
			opt[2]:1
		], countAllWS)
		
		
		XCTAssertEqual([
			opt[1]:1,
			opt[2]:1
		], countWo0WS)
		
		XCTAssertNotEqual([
			opt[0]:1,
			opt[1]:0,
			opt[2]:1
		], countWo0WS)
		
		XCTAssertEqual([
			opt[0]:1,
			opt[1]:1
		], countWo2WS)

		XCTAssertEqual([
			opt[1]:2
		], countWo02WS)
	
		
		let winner = try await vote.findWinner(force: false)
		XCTAssertEqual(Set(winner), [opt[0], opt[2]])
		print(winner, [opt[0], opt[2]])
		
		
		await vote.addVotes(SingleVote("NSA spy", rankings: opt))
		let failedCount = try? await vote.count()
		XCTAssertEqual(nil, failedCount)
		

    }
	
	
	
	func testBug() async throws{
		let options: [VoteOption] = ["1","2","3","4","5","6","7","8","9","10"]
		
		let votes: [SingleVote] = [.init("a", rankings: options),
								   .init("b", rankings: options),
								   .init("c", rankings: options.reversed()),
								   .init("d", rankings: [5,4,3,2,1,10,9,8,7,6].map{options[$0 - 1]})
		]
		
		
		let vote = Vote(id: UUID(), name: "", options: options, votes: votes, validators: [ VoteValidator.noBlankVotes,VoteValidator.everyoneHasVoted,VoteValidator.oneVotePerUser], eligibleVoters: [], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.removeRandom, TieBreaker.keepRandom])

		let nameOfWinner = try await vote.findWinner(force: false)[0].name
		XCTAssertEqual(nameOfWinner, "1")
		
	}
}
