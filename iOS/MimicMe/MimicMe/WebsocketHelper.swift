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

// Takes care of socket things and saving a message to core data.
extension TalkToBotController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        // {"command": "join", "room" : "idVar" }
//        let messageDictionary : [String: String] = [ "command": "join", "room": (room?.id)! ]
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
//            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
//            socket.write(string: jsonString)
//        } catch let err {
//            print(err)
//        }
        print("-------------------- socket connected ------------------")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("----------------------- disconnected ------------------")
        print(error as Any)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let incomingMsg = convertToDictionary(text: text)
        saveMessage(text: incomingMsg!["message"] as! String, isSender: false, room: room!)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // not using for now
    }
    
    // Saves message to phone memory
    func saveMessage(text: String, isSender: Bool, room: Room) {
        let aMessage = ChatMessage(context: PersistenceService.context)
        aMessage.text = text
        aMessage.isSender = isSender
        aMessage.room = room
        aMessage.date = Date() as NSDate
        PersistenceService.saveContext() // save to db
        messages.append(aMessage)
        collectionView?.reloadData()
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
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
        fetchRequest.predicate = NSPredicate(format: "room.id = %@", self.room!.id!)
        do {
            let chatLog = try PersistenceService.context.fetch(fetchRequest)
            return chatLog
        } catch let err {
            print(err)
        }
        return []
    }

}
