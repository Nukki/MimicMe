//
//  WebsocketHelper.swift
//  MimicMe
//
//  Created by Full Name on 3/15/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import Starscream

extension TalkToBotController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("-------------------- socket connected ------------------")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("----------------------- disconnected ------------------")
        print(error as Any)
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let incomingMsg = convertToDictionary(text: text)
        saveMessage(text: incomingMsg!["message"] as! String, isSender: false)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        //do something
    }
    
    func saveMessage(text: String, isSender: Bool) {
        let aMessage = ChatMessage(context: PersistenceService.context)
        aMessage.text = text
        aMessage.isSender = isSender
        aMessage.date = Date() as NSDate
        PersistenceService.saveContext() // save to db
        messages.append(aMessage)
        collectionView?.reloadData()
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

}
