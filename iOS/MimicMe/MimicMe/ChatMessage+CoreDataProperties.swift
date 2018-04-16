//
//  ChatMessage+CoreDataProperties.swift
//  MimicMe
//
//  Created by Nikki Jack on 4/7/18.
//  Copyright © 2018 N. All rights reserved.
//
//

import Foundation
import CoreData

// A model for chat messages.
// isSender field determins the color of message and its alignment further on.
// Each message is associated with a unique room
extension ChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessage> {
        return NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
    }

    @NSManaged public var isSender: Bool
    @NSManaged public var text: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var room: Room?

}
