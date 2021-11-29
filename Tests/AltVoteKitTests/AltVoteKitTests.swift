import XCTest
@testable import AltVoteKit

final class AltVoteKitTests: XCTestCase {
	func testExample() throws {
		runAsyncTest{
			let opt: [VoteOption] = ["Person 1", "Person 2", "Person 3"]
			
			let voter1 = Constituent(identifier: "Hans")
			let voter2 = Constituent(identifier: "Sofus")
			
			let vote = Vote(id: UUID(), name: "", options: opt, votes: [SingleVote(voter1, rankings: opt.reversed())], validators: VoteValidator.defaultValidators, constituents: [voter1], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.keepRandom])
			
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
			
			
			//And now with a second vote
			await vote.addConstituents(voter2)
			await vote.addVote(SingleVote(voter2, rankings: opt))
			
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
			
			// Tests removing a vote
			await vote.resetVoteForUser(voter2)
			await vote.setConstituents(await vote.constituents.filter { $0 != voter2})
			
			let newCount = try await vote.count()
			XCTAssertEqual(countAll, newCount)
			
			// Tests the "only verified" validator
			await vote.addVote(SingleVote("voter3", rankings: opt))
			let failedCount = try? await vote.count()
			XCTAssertEqual(nil, failedCount)
			
		}
	}
	
	
	
	func testSpecificCase() throws{
		runAsyncTest{
			let options: [VoteOption] = ["1","2","3","4","5","6","7","8","9","10"]
			
			let votes: [SingleVote] = [.init("a", rankings: options),
									   .init("b", rankings: options),
									   .init("c", rankings: options.reversed()),
									   .init("d", rankings: [5,4,3,2,1,10,9,8,7,6].map{options[$0 - 1]})
			]
			
			
			let vote = Vote(id: UUID(), name: "", options: options, votes: votes, validators: [ VoteValidator.noBlankVotes,VoteValidator.everyoneHasVoted,VoteValidator.oneVotePerUser], constituents: [], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.removeRandom, TieBreaker.keepRandom])
			
			let nameOfWinner = try await vote.findWinner(force: false)[0].name
			XCTAssertEqual(nameOfWinner, "1")
		}
	}
	
	
	// https://www.swiftbysundell.com/articles/unit-testing-code-that-uses-async-await/
	func runAsyncTest(named testName: String = #function, in file: StaticString = #file, at line: UInt = #line, withTimeout timeout: TimeInterval = 10, test: @escaping () async throws -> Void) {
		var thrownError: Error?
		let errorHandler = { thrownError = $0 }
		let expectation = expectation(description: testName)
		
		Task {
			do {
				try await test()
			} catch {
				errorHandler(error)
			}
			
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: timeout)
		
		if let error = thrownError {
			XCTFail(
				"Async error thrown: \(error)",
				file: file,
				line: line
			)
		}
	}

}

