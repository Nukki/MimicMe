//
//  ChatMessage+CoreDataProperties.swift
//  MimicMe
//
//  Created by Nikki Jack on 5/5/18.
//  Copyright © 2018 N. All rights reserved.
//
//

import Foundation
import CoreData


extension ChatMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessage> {
        return NSFetchRequest<ChatMessage>(entityName: "ChatMessage")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isSender: Bool
    @NSManaged public var text: String?
    @NSManaged public var uName: String?
    @NSManaged public var room: Room?

}
