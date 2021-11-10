//
//  File.swift
//  
//
//  Created by Hans Harck Tønning on 03/11/2021.
//

public struct UserInteractiveTieBreak: TieBreakable{
	public func breakTie(votes: [SingleVote], options: [Option], optionsLeft: Int) -> [String]{
		fatalError("User interactive tie breakers hasn't been implemented")
	}
	
}

extension TieBreaker{
	public static let userInteractiveTieBreak = UserInteractiveTieBreak()
}
