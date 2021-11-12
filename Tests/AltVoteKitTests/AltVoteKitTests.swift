import XCTest
@testable import AltVoteKit

final class AltVoteKitTests: XCTestCase {
    func testExample() async throws {
		let opt: [Option] = ["Person 1", "Person 2", "Person 3"]
		
		let vote = Vote(options: opt, votes: [SingleVote("Hans", rankings: opt.reversed())], validators: VoteValidator.defaultValidators, eligibleVoters: ["Hans"], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.keepRandom])
		
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
		await vote.addEligigbleVoters("Sofus")
		await vote.addVotes(SingleVote("Sofus", rankings: opt))
		
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
		
		
		await vote.addVotes(SingleVote("NSA spy", rankings: opt))
		let failedCount = try? await vote.count()
		XCTAssertEqual(nil, failedCount)

    }
}
