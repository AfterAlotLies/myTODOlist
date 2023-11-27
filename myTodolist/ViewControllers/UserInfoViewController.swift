//
//  UserInfoViewController.swift
//  myTodolist
//
//  Created by Vyacheslav on 20.11.2023.
//

import UIKit
import Alamofire

class UserInfoViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var titleArray = [String]()
    private var descriptionArray = [String]()
    private var importantTaskArray = [String]()
    private var tasksIdsArray = [Int]()
    
    private var tasks: [Task] = []
    
    private let numberOfSection = 3

    var selectedUserId: Int?
    private var countOfTasks: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getInfo()
    }
    
    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "createList", sender: nil)
    }
    
    @IBAction func backToRoot(_ sender: Any) {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    @objc
    func getInfo() {
        refreshArrays()
        let getInfoTask = GetRequests()
        getInfoTask.getInfoUsers { userInfo in
            if let userLog = userInfo {
                if let targetUser = userLog.first(where: { $0.id == self.selectedUserId} ) {
                    let taskTitles = targetUser.tasks.map { $0.title }
                    let taskDescription = targetUser.tasks.map { $0.description }
                    let taskId = targetUser.tasks.map { $0.id }
                    let taskImportant = targetUser.tasks.map { $0.importantTask }
                    
                    self.addToArrays(taskTitles: taskTitles,
                                     taskDescription: taskDescription,
                                     taskImportant: taskImportant,
                                     taskId: taskId)
                    
                    for (index, title) in self.titleArray.enumerated() {
                        let id = index + 1
                        let priority = self.importantTaskArray[index]
                        let description = self.descriptionArray[index]
                        let task = Task(id: id, title: title, description: description, importantTask: priority)
                        self.tasks.append(task)
                    }

                    self.tasks.sort { (task1: Task, task2: Task) in
                        return task1.importantTask < task2.importantTask
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createList" {
            let destinationVC = segue.destination as! NewTaskViewController
            destinationVC.selectedUserId = selectedUserId
            destinationVC.idOfTask = titleArray.count
            destinationVC.currentCountOfTasks = titleArray.count
        }
    }
}

// MARK: -  UserInfoViewController setup
extension UserInfoViewController {
    
    private func setup() {
        tableView.dataSource = self
    }
}
// MARK: - UserInfoViewController + UITableViewDataSource
extension UserInfoViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tasks.filter { $0.importantTask == "Срочно" }.count
        case 1:
            return tasks.filter { $0.importantTask != "Срочно" && $0.importantTask != "Не очень срочно" }.count
        case 2:
            return tasks.filter { $0.importantTask == "Не очень срочно" }.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserInfoTableViewCells

        switch indexPath.section {
        case 0:
            let urgentTasks = tasks.filter { $0.importantTask == "Срочно" }
            let task = urgentTasks[indexPath.row]
            cell.taskLabel.text = task.title
            cell.descriptionLabel.text = task.description
        case 1:
            let otherTasks = tasks.filter { $0.importantTask != "Срочно" && $0.importantTask != "Не очень срочно" }
            let task = otherTasks[indexPath.row]
            cell.taskLabel.text = task.title
            cell.descriptionLabel.text = task.description
        case 2:
            let notUrgentTasks = tasks.filter { $0.importantTask == "Не очень срочно" }
            let task = notUrgentTasks[indexPath.row]
            cell.taskLabel.text = task.title
            cell.descriptionLabel.text = task.description
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let currentUser = selectedUserId else { return }
            let selectedTask = tasks[indexPath.row]
            var deleteTask = DeleteRequests()
            deleteTask.deleteSelectedTask(currentUser: currentUser, selectedTask: selectedTask) {
                self.getInfo()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tasks.isEmpty {
            return 1
        } else {
            return numberOfSection
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tasks.isEmpty {
            return "Здесь будут ваши задания"
        } else {
            switch section {
            case 0:
                return "Срочно"
            case 1:
                return "В ближ. дни"
            case 2:
                return "Не очень срочно"
            default:
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if titleArray.isEmpty {
            return false
        } else {
            return true
        }
    }
}

// MARK: - UserInfoViewController + Arrays funcs
extension UserInfoViewController {
    
    private func addToArrays(taskTitles: [String], taskDescription: [String], taskImportant: [String],taskId: [Int]) {
        titleArray.append(contentsOf: taskTitles)
        descriptionArray.append(contentsOf: taskDescription)
        tasksIdsArray.append(contentsOf: taskId)
        importantTaskArray.append(contentsOf: taskImportant)
    }
    
    private func refreshArrays() {
        titleArray.removeAll(keepingCapacity: false)
        descriptionArray.removeAll(keepingCapacity: false)
        tasksIdsArray.removeAll(keepingCapacity: false)
        importantTaskArray.removeAll(keepingCapacity: false)
        tasks.removeAll(keepingCapacity: false)
    }
}
