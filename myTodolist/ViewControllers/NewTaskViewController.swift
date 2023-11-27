//
//  NewTaskViewController.swift
//  myTodolist
//
//  Created by Vyacheslav on 22.11.2023.
//

import UIKit

class NewTaskViewController: UIViewController {

    @IBOutlet private weak var typeTask: UISegmentedControl!
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var descriptionField: UITextField!
    
    var selectedUserId: Int?
    var idOfTask: Int?
    private var importantTask: String = LocalizatedSegmentControlCases.notImmediatly.rawValue
    var currentCountOfTasks: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addTask(_ sender: Any) {
        addNewTask()
    }
    
    private func addNewTask() {
        guard let title = titleField.text,
              let description = descriptionField.text,
              let id = idOfTask else { return }
        if title == "" && description == "" {
            errorMessage(title: "Упс, что-то пошло не так", message: "Вы же не заполнили ничего :(")
        } else {
            let newTask = Task(id: id + 1,
                               title: title,
                               description: description,
                               importantTask: importantTask)
            
            let postRequest = PostRequests()
            guard let targetUserId = selectedUserId else {
                return
            }
            postRequest.addNewTask(currentUser: targetUserId, newTask: newTask) {
                self.readCurrentInfo()
            }
        }
    }
    
    private func readCurrentInfo() {
        let getRequest = GetRequests()
        getRequest.getInfoUsers { userInfo in
            if let userLog = userInfo {
                if let targetUser = userLog.first(where: {$0.id == self.selectedUserId}) {
                    if let currentTask = self.currentCountOfTasks {
                        let nowCountOfTask = targetUser.tasks.count
                        if nowCountOfTask > currentTask {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - NewTaskViewController + SegmentControls
extension NewTaskViewController {
    
    @IBAction func taskManager(_ sender: UISegmentedControl) {
        if let selectedCase = SegmentControlCases(rawValue: sender.selectedSegmentIndex) {
            switch selectedCase {
            case .inNextDays:
                importantTask = LocalizatedSegmentControlCases.inNextDays.rawValue
            case .immediatly:
                importantTask = LocalizatedSegmentControlCases.immediatly.rawValue
            default:
                importantTask = LocalizatedSegmentControlCases.notImmediatly.rawValue
            }
        }
    }
}

// MARK: - ErrorMessage
extension NewTaskViewController {
    
    private func errorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Понял!", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

