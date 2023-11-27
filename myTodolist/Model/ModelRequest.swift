//
//  ModelRequest.swift
//  myTodolist
//
//  Created by Vyacheslav on 20.11.2023.
//

import Foundation

struct User: Codable {
    var id: Int
    var name: String
    var age: String
    var tasks: [Task]
    var profileImage: Data
}

struct Task: Codable {
    var id: Int
    var title: String
    var description: String
    var importantTask: String
}


