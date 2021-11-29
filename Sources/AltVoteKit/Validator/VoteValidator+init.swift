// Adds some convenience initialisers to Validator
extension VoteValidator{
	public init(id: String, name: String, offenseText: @Sendable @escaping (_ for: SingleVote) -> String, closure: @escaping closureType){
		self.init(id: id, name: name, offenseText: {u, o in offenseText(u)}, closure: closure)
	}
	
	public init(id: String, name: String, offenseText: @Sendable @escaping (_ for: SingleVote, _ options: [VoteOption]) -> String, closure: @Sendable @escaping ([SingleVote], _ constituents: Set<Constituent>) -> [SingleVote]){
		self.init(id: id, name: name, offenseText: offenseText, closure: {votes, constituents, options in closure(votes, constituents)})
	}
	
	public init(id: String, name: String, offenseText: @Sendable @escaping (_ for: SingleVote) -> String, closure: @Sendable @escaping ([SingleVote], _ constituents: Set<Constituent>) -> [SingleVote]){
		self.init(id: id, name: name, offenseText: {u, o in offenseText(u)}, closure: {votes, constituents, options in closure(votes, constituents)})
	}
}
