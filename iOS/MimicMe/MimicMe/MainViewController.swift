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
    var jsonArr: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55;
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        rooms = getRoomsFromServer() // get data to fill the table every time the view appears
        tableView.reloadData()
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
        let memoryRooms = loadRoomsFromMemory()
        
        // make a header for request
        guard let url = URL(string: "http://127.0.0.1:8000/chat/rooms") else { return memoryRooms}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type");

        // make a request
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else {return}
            do {
                let responseRooms = try JSONDecoder().decode([RoomFromJson].self, from: data) // decode as array of roomJson struct
                if (memoryRooms.count < responseRooms.count) {
                    print("There are new rooms to save")
                    self.saveNewRooms(rooms: responseRooms)
                }

            } catch {}
        }.resume()
        return memoryRooms
    }
    
//    func fakeGetRooms(data: Data)-> [Room] {
//        let memoryRooms = loadRoomsFromMemory()
//        print("rooms in memory: ", memoryRooms.count)
//        do {
//            let responseRooms = try JSONDecoder().decode([RoomFromJson].self, from: data) // decode as array of roomfromJson struct
//            print(responseRooms[0].id)
//            if (memoryRooms.count < responseRooms.count) {
//                print("There are new rooms to save")
//                saveNewRooms(rooms: responseRooms)
//            }
//        }catch {}
//        return loadRoomsFromMemory()
//    }
    
    func saveNewRooms(rooms: [RoomFromJson]) {
        for room in rooms {
            if( !roomExists(id: room.id) ){
                saveRoom(id: room.id, name: room.name)
            }
        }
    }
    
    func roomExists(id: Int32) -> Bool {
        let fetchRequest: NSFetchRequest<Room> = Room.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == \(id)")
        var results: [NSManagedObject] = []
        do {
            results = try PersistenceService.context.fetch(fetchRequest)
        } catch let err {
            print(err)
        }
        return results.count > 0
    }
    
    func loadRoomsFromMemory() -> [Room] {
        let fetchRequest: NSFetchRequest<Room> = Room.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            let roomList = try PersistenceService.context.fetch(fetchRequest)
            return roomList
        } catch let err {
            print(err)
        }
        return []
    }
    
    func saveRoom(id: Int32, name: String) {
        print("Trying to save a room: ", name)
        let aRoom = Room(context: PersistenceService.context)
        aRoom.id = id
        aRoom.name = name
        PersistenceService.saveContext() // save to db
        rooms.append(aRoom)
        DispatchQueue.main.async {
            self.tableView.reloadData() // update table
        }
    }
    
    
    // *********************** Buttons Actions ******************************
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "secret")
        self.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "letmein", sender: self)
    }
} // end MainViewController

// struct for parsing JSON to Room
struct RoomFromJson: Decodable {
    let id: Int32
    let name: String
}



