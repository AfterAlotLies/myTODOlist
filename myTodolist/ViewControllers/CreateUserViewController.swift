//
//  CreateViewController.swift
//  myTodolist
//
//  Created by Vyacheslav on 20.11.2023.
//

import UIKit
import Alamofire

class CreateUserViewController: UIViewController {

    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var regUserButton: UIButton!
    
    private var createdUserId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func regUser(_ sender: Any) {
        if nameTextField.text == ""  && ageTextField.text == ""{
            makeAlert(title: "Упс, что-то не так", message: "Укажите свое имя и возраст, чтобы продолжить!")
        } else {
            addNewUser()
            let getRequest = GetRequests()
            getRequest.getInfoUsers { user in
                if let userLog = user {
                    if let newUser = userLog.last {
                        self.createdUserId = newUser.id
                    }
                }
                self.performSegue(withIdentifier: "showUserList", sender: nil)
            }
            nameTextField.text = ""
            ageTextField.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserList" {
            let destination = segue.destination as! UserInfoViewController
            destination.selectedUserId = createdUserId
        }
    }
}

// MARK: - send POST request to add new user
extension CreateUserViewController {
        
    private func addNewUser() {
        guard let name = nameTextField.text, let age = ageTextField.text else { return }
        
        let newUser = User(id: 0,
                           name: name,
                           age: age,
                           tasks: [])
        
        let postRequest = PostRequests()
        let getRequest = GetRequests()
        postRequest.addNewUser(newUser: newUser)
        getRequest.getInfoUsers { user in
            if let userLog = user {
                if let newUser = userLog.last {
                    self.createdUserId = newUser.id
                }
            }
        }
    }
}

// MARK: - alert error message
extension CreateUserViewController {
    
    private func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let okButton = UIAlertAction(title: "Понял!", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
