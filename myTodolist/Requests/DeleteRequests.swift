//
//  DeleteUserFromServer.swift
//  myTodolist
//
//  Created by Vyacheslav on 21.11.2023.
//

import Foundation
import Alamofire

struct DeleteRequests {
    
    private var apiDeleteUserKey: String = ""
    
    mutating func deleteUser(userInfo: User) {
        apiDeleteUserKey = "http://localhost:3000/users/\(userInfo.id)"
        AF.request(apiDeleteUserKey, 
                   method: .delete,
                   parameters: userInfo).responseDecodable(of: [User].self) { response in
            switch response.result {
            case .success(_):
                print("success to delete user")
            case .failure(let error):
                print("Error to delete user request:\(error.localizedDescription)")
            }
        }
    }
    
   mutating func deleteSelectedTask(currentUser: Int, selectedTask: Task, completion: @escaping () -> Void) {
        apiDeleteUserKey = "http://localhost:3000/users/\(currentUser)"
        AF.request(apiDeleteUserKey, method: .get).responseDecodable(of: User.self) { [self] response in
            switch response.result {
            case .success(var existingUser):
                existingUser.tasks.removeAll { $0.id == selectedTask.id }
                
                for (index, _) in existingUser.tasks.enumerated() {
                    existingUser.tasks[index].id = index + 1
                }
                
                let putRequest = PutRequest()
                
                putRequest.putRequest(url: apiDeleteUserKey,
                                      existingUser: existingUser,
                                      selectedTask: selectedTask)
                
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
