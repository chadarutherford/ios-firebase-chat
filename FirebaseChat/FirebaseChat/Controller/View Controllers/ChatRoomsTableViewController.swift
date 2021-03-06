//
//  ChatRoomsTableViewController.swift
//  FirebaseChat
//
//  Created by Chad Rutherford on 1/28/20.
//  Copyright © 2020 chadarutherford.com. All rights reserved.
//

import UIKit

class ChatRoomsTableViewController: UITableViewController {
    
    let chatRoomController = ChatRoomController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoom))
        chatRoomController.fetchRooms {
            self.tableView.reloadData()
        }
    }
    
    @objc private func addRoom() {
        let alert = UIAlertController(title: "Add A Room", message: "Please enter the name for the room to be added.", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            guard let textField = alert.textFields?.first, let name = textField.text, !name.isEmpty else { return }
            self.chatRoomController.addRoom(with: name) {
                self.chatRoomController.fetchRooms {
                    self.dismiss(animated: true)
                    self.tableView.reloadData()
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowMessagesSegue":
            guard let destinationVC = segue.destination as? ChatRoomDetailViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            let room = chatRoomController.rooms[indexPath.row]
            destinationVC.chatRoomController = chatRoomController
            destinationVC.room = room
        default:
            break
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomController.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        let room = chatRoomController.rooms[indexPath.row]
        cell.textLabel?.text = room.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let room = chatRoomController.rooms[indexPath.row]
            chatRoomController.deleteRoom(room) {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
}
