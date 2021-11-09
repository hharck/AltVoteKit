// Adds some convenience initialisers to Validator
extension Validator{
	public init(id: String, name: String, offenseText: @escaping (_ for: SingleVote) -> String, closure: @escaping closureType){
		self.init(id: id, name: name, offenseText: {u, o in offenseText(u)}, closure: closure)
	}
	
	public init(id: String, name: String, offenseText: @escaping (_ for: SingleVote, _ options: [Option]) -> String, closure: @escaping ([SingleVote], _ eligibleUsers: Set<UserID>) -> [SingleVote]){
		self.init(id: id, name: name, offenseText: offenseText, closure: {votes, eligigbleUsers, options in closure(votes, eligigbleUsers)})
	}
	
	public init(id: String, name: String, offenseText: @escaping (_ for: SingleVote) -> String, closure: @escaping ([SingleVote], _ eligibleUsers: Set<UserID>) -> [SingleVote]){
		self.init(id: id, name: name, offenseText: {u, o in offenseText(u)}, closure: {votes, eligigbleUsers, options in closure(votes, eligigbleUsers)})
	}
}
