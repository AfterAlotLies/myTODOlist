//
//  GetInfoFromServer.swift
//  myTodolist
//
//  Created by Vyacheslav on 20.11.2023.
//

import Foundation
import Alamofire

struct GetRequests {
    
    private let apiKeyGet = "http://localhost:3000/users"
    
    func getInfoUsers(completion: @escaping ([User]?) -> Void) {
        AF.request(apiKeyGet, 
                   method: .get).responseDecodable(of: [User].self) { response in
            switch response.result {
            case .success(let userInfo):
                completion(userInfo)
            case .failure(let error):
                print("Error to get user request: \(error.localizedDescription)")
            }
        }
    }
}
