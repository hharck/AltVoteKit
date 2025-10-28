import XCTest
import VoteKit
@testable import AltVoteKit

final class AltVoteKitTests: XCTestCase {
	func testCount() async throws {
			let opt: [VoteOption] = ["Person 1", "Person 2", "Person 3"]

			let voter1 = Constituent.init(identifier: "Hans", tag: "Group1")
			let voter2 = Constituent.init(identifier: "Sofus", tag: "Group2")

        let vote = AlternativeVote(name: "", options: opt, votes: [SingleVote(voter1, rankings: opt.reversed())], constituents: [voter1], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.keepRandom], genericValidators: GenericValidator.allValidators, customValidators: [])

			let countAll = try await vote.count()
			let countWo0 = try await vote.count(force: false, excluding: [opt[0]])
			let countWo2 = try await vote.count(force: false, excluding: [opt[2]])

			print(countAll)

			XCTAssertEqual([
				opt[0]: 0,
				opt[1]: 0,
				opt[2]: 1
			], countAll)

			XCTAssertEqual([
				opt[1]: 0,
				opt[2]: 1
			], countWo0)

			XCTAssertNotEqual([
				opt[0]: 0,
				opt[1]: 0,
				opt[2]: 1
			], countWo0)

			XCTAssertEqual([
				opt[0]: 0,
				opt[1]: 1
			], countWo2)

			// And now with a second vote
			await vote.addConstituents(voter2)
			await vote.addVote(SingleVote(voter2, rankings: opt))

			let countAllWS = try await vote.count()
			let countWo0WS = try await vote.count(force: false, excluding: [opt[0]])
			let countWo2WS = try await vote.count(force: false, excluding: [opt[2]])
			let countWo02WS = try await vote.count(force: false, excluding: [opt[0], opt[2]])

			XCTAssertEqual([
				opt[0]: 1,
				opt[1]: 0,
				opt[2]: 1
			], countAllWS)

			XCTAssertEqual([
				opt[1]: 1,
				opt[2]: 1
			], countWo0WS)

			XCTAssertNotEqual([
				opt[0]: 1,
				opt[1]: 0,
				opt[2]: 1
			], countWo0WS)

			XCTAssertEqual([
				opt[0]: 1,
				opt[1]: 1
			], countWo2WS)

			XCTAssertEqual([
				opt[1]: 2
			], countWo02WS)

			let winner = try await vote.findWinner(force: false).winners()
			XCTAssertEqual(Set(winner), [opt[0], opt[2]])

			// Tests removing a vote
			await vote.resetVoteForUser(voter2)
			await vote.setConstituents(await vote.constituents.filter { $0 != voter2})

			let newCount = try await vote.count()
			XCTAssertEqual(countAll, newCount)
	}

	func testCSV() async throws {
			let opt: [VoteOption] = ["Person 1", "Person 2", "Person 3"]

			let voter1 = Constituent.init(identifier: "Hans", tag: "Group1")
			let voter2 = Constituent.init(identifier: "Sofus", tag: "Group2")

			let basicVotes = [SingleVote(voter1, rankings: opt.reversed()), SingleVote(voter2, rankings: Array(opt.dropFirst()))]
        let vote2 = AlternativeVote(name: "", options: opt, votes: basicVotes, constituents: [voter1, voter2], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.keepRandom], genericValidators: GenericValidator.allValidators, customValidators: [])

			// CSV:
			func testCSVWithConf(_ v: AlternativeVote, config: CSVConfiguration, withTags: Bool) async {
				let csv = await v.toCSV(config: config)
				let nVote: AlternativeVote! = AlternativeVote.fromCSV(config: config, csv)
				XCTAssertNotNil(nVote)

				let nOptions = Set(await nVote.options.map(\.name))
				let oOptions = Set(await v.options.map(\.name))

				XCTAssertEqual(nOptions, oOptions)

				let nVotes = await nVote.votes
					.sorted {$0.constituent.identifier < $1.constituent.identifier}
					.map {($0.constituent, $0.rankings.map(\.name))}
				let oVotes = await v.votes
					.sorted {$0.constituent.identifier < $1.constituent.identifier}
					.map {($0.constituent, $0.rankings.map(\.name))}

				let nC = nVotes.map(\.0)
				var oC = oVotes.map(\.0)
				if !withTags {
					oC = oC.map(rmTag)
				}

				let nR = nVotes.map(\.1)
				let oR = oVotes.map(\.1)

				// Compares constituents who has cast a vote
				XCTAssertEqual(nC, oC)

				// Compares the specific vote of a constituent
				XCTAssertEqual(nR, oR)

				let nConstituents = await nVote.constituents// .sorted(by: {$0.identifier < $1.identifier})
				var oConstituents = await v.constituents// .sorted(by: {$0.identifier < $1.identifier})

				// Removes tags from constituents if tags aren't part of this test
				if !withTags {
					oConstituents = Set(oConstituents.map(rmTag))
				}
				XCTAssertEqual(nConstituents, oConstituents)

				func rmTag(_ const: Constituent) -> Constituent {
					var const = const
					const.tag = nil
					return const
				}
			}

			await testCSVWithConf(vote2, config: .defaultConfiguration(), withTags: false)
			await testCSVWithConf(vote2, config: .SMKid(), withTags: false)
			await testCSVWithConf(vote2, config: .defaultWithTags(), withTags: true)
	}

	func testSpecificCase() async throws {
        let options: [VoteOption] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

        let votes: [SingleVote] = [.init("a", rankings: options),
                                   .init("b", rankings: options),
                                   .init("c", rankings: options.reversed()),
                                   .init("d", rankings: [5, 4, 3, 2, 1, 10, 9, 8, 7, 6].map {options[$0 - 1]})
        ]

        let vote = AlternativeVote(name: "", options: options, votes: votes, constituents: [], tieBreakingRules: [TieBreaker.dropAll, TieBreaker.removeRandom, TieBreaker.keepRandom], genericValidators: [.everyoneHasVoted, .noBlankVotes], customValidators: [])

        let nameOfWinner = try await vote.findWinner(force: false).winners().first!.name
        XCTAssertEqual(nameOfWinner, "1")
	}
}
