//
//  MainViewController.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/1/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MainViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var rooms = [Room]() // data for rooms table
   
    override func viewDidLoad() {
        super.viewDidLoad()
        saveRooms()
        tableView.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 65;
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // ******************* TableView setup ******************************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.item] as Room
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        cell.textLabel?.text = room.name
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = TalkToBotController(collectionViewLayout: layout)
        let room = rooms[indexPath.item] as Room
        controller.room = room
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    // ********************** Core Data Manipulations ****************************
    
    func getRoomsFromServer() -> [Room] {
        return []
    }
    
    func loadRoomsFromMemory() -> [Room] {
        let fetchRequest: NSFetchRequest<Room> = Room.fetchRequest()
        do {
            let roomList = try PersistenceService.context.fetch(fetchRequest)
            return roomList
        } catch let err {
            print(err)
        }
        return []
    }
    
    func saveRooms() {
        let aRoom = Room(context: PersistenceService.context)
        aRoom.id = "1"
        aRoom.name = "1337room"
        let anotherRoom = Room(context: PersistenceService.context)
        anotherRoom.id = "2"
        anotherRoom.name = "n00broom"
        PersistenceService.saveContext() // save to db
        rooms.append(aRoom)
        rooms.append(anotherRoom)
        tableView?.reloadData()
    }
    
    
    // *********************** Buttons actions ******************************
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "ayyy")
        self.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "letmein", sender: self)
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        displayAlertMessage("Turing Test is when you determine if you're talking to AI or a real human. Can you tell which user in a chat is bot?")
    }
    
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "What is a Turing Test?", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
}



