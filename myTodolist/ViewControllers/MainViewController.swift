//
//  MainAppViewController.swift
//  myTodolist
//
//  Created by Vyacheslav on 20.11.2023.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var namesArray = [String]()
    private var idsArray = [Int]()
    private var agesArray = [String]()
    
    private var selectedUserId: Int?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshArrays()
        let getInfo = GetRequests()
        getInfo.getInfoUsers { userInfo in
            if let userInfo = userInfo {
                for user in userInfo {
                    self.addInfoToArrays(user: user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            let destinationVC = segue.destination as! UserInfoViewController
            destinationVC.selectedUserId = selectedUserId
        }
    }
    
    @IBAction func createNewUser(_ sender: Any) {
        performSegue(withIdentifier: "createNewUser", sender: nil)
    }
}

// MARK: - MainViewController setup
extension MainViewController {
    
    func setup(){
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "TodoList"
    }
}

// MARK: - Arrays funcs
extension MainViewController {
    
    private func refreshArrays() {
        namesArray.removeAll(keepingCapacity: false)
        idsArray.removeAll(keepingCapacity: false)
        agesArray.removeAll(keepingCapacity: false)
    }
    
    private func addInfoToArrays(user: User) {
        namesArray.append(user.name)
        idsArray.append(user.id)
        agesArray.append(user.age)
    }
    
    private func removeFromArray(indexPath: IndexPath) {
        namesArray.remove(at: indexPath.row)
        idsArray.remove(at: indexPath.row)
        agesArray.remove(at: indexPath.row)
    }
}

// MARK: - MainViewController + UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if namesArray.isEmpty && namesArray.first != "" {
            return 1
        } else {
            return namesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", 
                                                 for: indexPath) as! MainTableViewCells
        if namesArray.isEmpty {
            cell.usernameLabel.text = "Пока еще никто не пользовался =("
            cell.usernameLabel.textAlignment = .center
            cell.isUserInteractionEnabled = false
            tableView.isScrollEnabled = false
            tableView.separatorStyle = .none
            return cell
        } else {
            cell.usernameLabel.text = namesArray[indexPath.row]
            cell.isUserInteractionEnabled = true
            cell.usernameLabel.textAlignment = .left
            tableView.isScrollEnabled = true
            tableView.separatorStyle = .singleLine
            return cell
        }
    }
}

// MARK: - MainViewController + UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let userInfo = User(id: idsArray[indexPath.row],
                                name: namesArray[indexPath.row],
                                age: agesArray[indexPath.row],
                                tasks: [])
            
            var deleteUser = DeleteRequests()
            deleteUser.deleteUser(userInfo: userInfo)
            removeFromArray(indexPath: indexPath)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUserId = idsArray[indexPath.row]
        performSegue(withIdentifier: "showProfile", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if namesArray.isEmpty {
            return false
        } else {
            return true
        }
    }
    
}
