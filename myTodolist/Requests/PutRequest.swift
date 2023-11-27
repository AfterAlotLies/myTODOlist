//
//  PutRequest.swift
//  myTodolist
//
//  Created by Vyacheslav on 22.11.2023.
//

import Foundation
import Alamofire

struct PutRequest {
  
    func putRequest(url: String, existingUser: User, completion: (() -> Void)? = nil, selectedTask: Task? = nil) {
        AF.request(url,
                   method: .put,
                   parameters: existingUser,
                   encoder: JSONParameterEncoder.default).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success(_):
                print("success addNewTask func")
                completion?()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
