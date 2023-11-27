//
//  AddNewUserRequest.swift
//  myTodolist
//
//  Created by Vyacheslav on 20.11.2023.
//

import Foundation
import Alamofire

struct PostRequests {
    private let apiPostUserKey = "http://localhost:3000/users"
    
    func addNewUser(newUser: User) {
        AF.request(apiPostUserKey, 
                   method: .post,
                   parameters: newUser,
                   encoder: JSONParameterEncoder.default).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success(_):
                print("success addNewUser func")
            case .failure(let error):
                print("Error to post user request: \(error.localizedDescription)")
            }
        }
    }
    
    func addNewTask(currentUser: Int, newTask: Task, completion: @escaping () -> Void) {
        let apiPostTaskKey = "http://localhost:3000/users/\(currentUser)"
        AF.request(apiPostTaskKey,
                   method: .get).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success(var existingUser):
                existingUser.tasks.append(newTask)
                let putRequest = PutRequest()
                putRequest.putRequest(url: apiPostTaskKey, existingUser: existingUser)
                completion()
            case .failure(let error):
                print("Error loading user: \(error.localizedDescription)")
            }
        }
    }

}
