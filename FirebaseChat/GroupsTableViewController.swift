//
//  ChatsTableViewController.swift
//  FirebaseChat
//
//  Created by Alex Alexandrovych on 21/11/2016.
//  Copyright © 2016 Alex Alexandrovych. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin

final class GroupsTableViewController: UITableViewController {
        
    private enum Section: Int {
        case createNewGroupSection = 0
        case currentGroupsSection
    }
    
    // MARK: Properties
    var senderDisplayName: String?
    var newGroupTextField: UITextField?
    
    private var groups: [Group] = []
    private lazy var groupRef: FIRDatabaseReference = FIRDatabase.database().reference().child("groups")
    private var groupRefHandle: FIRDatabaseHandle?
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = senderDisplayName

    }
    
    deinit {
        if let refHandle = groupRefHandle {
            groupRef.removeObserver(withHandle: refHandle)
        }
    }

    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        do {
            LoginManager().logOut()
            try FIRAuth.auth()?.signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            print("Cannot logout: \(error.localizedDescription)")
        }

    }
    
    @IBAction func createGroup(_ sender: UIButton) {
        if let name = newGroupTextField?.text {
            let newGroupRef = groupRef.childByAutoId()
            let groupItem = [
                "name": name,
                "creator": senderDisplayName
            ]
            newGroupRef.setValue(groupItem)
            newGroupTextField?.text = ""
        }
    }
    
    fileprivate func showLoginScreen() {
        performSegue(withIdentifier: "ShowLoginScreen", sender: self)
    }
    
    // MARK: Firebase related methods
    private func observeGroups() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        groupRefHandle = groupRef.observe(.childAdded, with: { snapshot in
            let id = snapshot.key
            if let groupData = snapshot.value as? [String: Any],
                let name = groupData["name"] as? String,
                let creator = groupData["creator"] as? String,
                name.characters.count > 0 {
                self.groups.append(Group(id: id, name: name, creator: creator))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode group data")
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewGroupSection:
                return 1
            case .currentGroupsSection:
                return groups.count
            }
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == Section.createNewGroupSection.rawValue ? "CreateGroupCell" : "GroupCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if indexPath.section == Section.createNewGroupSection.rawValue {
            if let createNewGroupCell = cell as? CreateGroupCell {
                newGroupTextField = createNewGroupCell.newGroupNameField
            }
        } else if indexPath.section == Section.currentGroupsSection.rawValue {
            cell.textLabel?.text = groups[indexPath.row].name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentGroupsSection.rawValue {
            let group = groups[indexPath.row]
            self.performSegue(withIdentifier: "ShowChat", sender: group)
        }
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Section.createNewGroupSection.rawValue {
            return false
        } else if indexPath.section == Section.currentGroupsSection.rawValue {
            return true
        }
        return false
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let group = sender as? Group {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.senderDisplayName = senderDisplayName
                chatVC.group = group
                chatVC.groupRef = groupRef.child(group.id)
            }
        }
        
    }
    
}
