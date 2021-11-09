// Adds some convenience initialisers to Validator
extension Validator{
	public init(name: String, offenseText: @escaping (_ for: SingleVote) -> String, closure: @escaping closureType){
		self.init(name: name, offenseText: {u, o in offenseText(u)}, closure: closure)
	}
	
	public init(name: String, offenseText: @escaping (_ for: SingleVote, _ options: [Option]) -> String, closure: @escaping ([SingleVote], _ eligibleUsers: Set<UserID>) -> [SingleVote]){
		self.init(name: name, offenseText: offenseText, closure: {votes, eligigbleUsers, options in closure(votes, eligigbleUsers)})
	}
	
	public init(name: String, offenseText: @escaping (_ for: SingleVote) -> String, closure: @escaping ([SingleVote], _ eligibleUsers: Set<UserID>) -> [SingleVote]){
		self.init(name: name, offenseText: {u, o in offenseText(u)}, closure: {votes, eligigbleUsers, options in closure(votes, eligigbleUsers)})
	}
}
