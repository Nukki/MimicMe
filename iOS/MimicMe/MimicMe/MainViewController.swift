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
        jsonArr = "[{\"name\":\"1337room\",\"id\":\"1\"},{\"name\":\"n00broom\",\"id\":\"2\"},{\"name\":\"S*itPoster\",\"id\":\"3\"},{\"name\":\"SrsBzns\",\"id\":\"4\"}]"
        let data = jsonArr?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        rooms = fakeGetRooms(data: data!)
//        getRoomsFromServer()
        tableView.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55;
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
        let memoryRooms = loadRoomsFromMemory()
        
        // make a header for request
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return memoryRooms}
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
                let responseRooms = try JSONDecoder().decode([decStuff].self, from: data) // decode as array of roomJson struct
                if (memoryRooms.count < responseRooms.count) {
//                    saveNewRooms(responseRooms) do it with closure
                }

            } catch {}
        }.resume()

        return memoryRooms
    }
    
    func fakeGetRooms(data: Data)-> [Room] {
        let memoryRooms = loadRoomsFromMemory()
        print("rooms in memory: ", memoryRooms.count)
        do {
            let responseRooms = try JSONDecoder().decode([RoomFromJson].self, from: data) // decode as array of roomfromJson struct
            print(responseRooms[0].id)
            if (memoryRooms.count < responseRooms.count) {
                print("There are new rooms to save")
                saveNewRooms(rooms: responseRooms)
            }
        }catch {}
        return loadRoomsFromMemory()
    }
    
    func saveNewRooms(rooms: [RoomFromJson]) {
        for room in rooms {
            if(!roomExists(id: room.id)){
                saveRoom(id: room.id, name: room.name)
            }
        }
    }
    
    func roomExists(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<Room> = Room.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
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
        do {
            let roomList = try PersistenceService.context.fetch(fetchRequest)
            return roomList
        } catch let err {
            print(err)
        }
        return []
    }
    
    func saveRoom(id: String, name: String) {
        print("Trying to save a room: ", name)
        let aRoom = Room(context: PersistenceService.context)
        aRoom.id = id
        aRoom.name = name
        PersistenceService.saveContext() // save to db
        rooms.append(aRoom)
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


// struct for parsing JSON to Room
struct RoomFromJson: Decodable {
    let id: String
    let name: String
}

struct decStuff: Decodable {
    let id: Int
    let body: String
    let title: String
    let userId: Int
}


