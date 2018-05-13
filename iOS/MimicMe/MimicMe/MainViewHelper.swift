//
//  MainViewHelper.swift
//  MimicMe
//
//  Created by Full Name on 5/12/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import PKHUD

extension MainViewController {
    
    // *************** Query Server For a List of Rooms ************************
    
    func getRoomsFromServer() -> [Room] {
        let memoryRooms = loadRoomsFromMemory()
        
        // make a header for request
        guard let url = URL(string: "http://159.65.38.56:8000/chat/rooms") else { return memoryRooms}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type");
        
        // make a request
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 20.0
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                if error?._code == NSURLErrorTimedOut {
                    DispatchQueue.main.async {
                        HUD.hide()
                        self.displayAlertMessage("Check your Internet connection. Failed to connect with server")
                    }
                }
                print(error!.localizedDescription)
            }
            if let resp = response as? HTTPURLResponse {
                print("Get rooms response code: ", resp.statusCode)
                if resp.statusCode == 200 {
                    guard let data = data else {return}
                    do {
                        let responseRooms = try JSONDecoder().decode([RoomFromJson].self, from: data) // decode as array of room structs
                        if (memoryRooms.count < responseRooms.count) {
                            self.saveNewRooms(rooms: responseRooms)
                        }
                    } catch { print("Could not parse rooms JSON") }
                }
            } // end outer if
            DispatchQueue.main.async {
                HUD.hide() // hide progress animation
            }
        }.resume( )
        return loadRoomsFromMemory()
    } // end getRoomsFromServer
    
    // ********************** Core Data Manipulations ****************************
    
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
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
} // end extension
