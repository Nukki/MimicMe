//
//  WebsocketHelper.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/15/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import Starscream
import CoreData
import UIKit

// Takes care of socket things and saving a message to core data.
extension TalkToBotController: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        // joing the room as soon as socket connected
        let myID = Int32(UserDefaults.standard.integer(forKey: "secret"))
        let myUsername = UserDefaults.standard.string(forKey: "uname")
        let joinMsg = JoinMsg(command: "join", room: (room?.id)!, username: myUsername!, uid: myID)
        let encodedData = try? JSONEncoder().encode(joinMsg)
        if let jsonData = encodedData {
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            socket.write(string: jsonString)
        }
        print("-------------------- socket connected ------------------")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("----------------------- disconnected ------------------")
        if let er: Starscream.WSError = error as? WSError {
            print("Socket disconnected with: ", er.code)
            if (er.code != 1000) {
                print(er)
                displayAlertMessage("Disconnected from chat", actionName: "Reconnect")
            }
        } else {
            displayAlertMessage("Disconnected from chat", actionName: "Reconnect")
            print("Error: ", error as Any);
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let myUsername: String = UserDefaults.standard.string(forKey: "uname")!
        let incomingMsg = convertToDictionary(text: text)
//        print("incoming json: ", incomingMsg ?? "no json")
        if (incomingMsg != nil && incomingMsg!["message"] != nil) {
            let u: String = incomingMsg!["username"] as! String
            if (u != myUsername) {
                saveMessage(text: incomingMsg!["message"] as! String, isSender: false, room: room!, user: u)
            }
            else {
                saveMessage(text: incomingMsg!["message"] as! String, isSender: true, room: room!, user: u)
            }
        }
        else {
            print("Joined the rooom")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // not using for now
        print("RECEIVED DATA")
    }
    
    // Saves message to phone memory
    func saveMessage(text: String, isSender: Bool, room: Room, user: String) {
        let aMessage = ChatMessage(context: PersistenceService.context)
        aMessage.text = text
        aMessage.isSender = isSender
        aMessage.room = room
        aMessage.uName = user
        aMessage.date = Date() as NSDate
        PersistenceService.saveContext() // save to db
        messages.append(aMessage)
        collectionView?.reloadData()
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    // convert JSON to Swift dictionary
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // gets data from memory ( fills messages array)
    func loadMessagesFromMemory() -> [ChatMessage] {
        let fetchRequest: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "room.id == \(self.room!.id)")
        do {
            let chatLog = try PersistenceService.context.fetch(fetchRequest)
            return chatLog
        } catch let err {
            print(err)
        }
        return []
    }
    
    struct JoinMsg : Codable {
        let command: String
        let room: Int32
        let username: String
        let uid: Int32
    }
    
    // displays given error message in a pop-up alert view
    // @param userMessage is the explanation of the error
    func displayAlertMessage(_ userMessage: String, actionName: String) {
        let theAlert = UIAlertController(title: "Error", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: actionName, style: UIAlertActionStyle.default, handler: reconnect)
        theAlert.addAction(okAction)
        self.present(theAlert, animated: true, completion: nil)
    }
    
    func reconnect(action: UIAlertAction) {
        socket.connect()
    }

}
