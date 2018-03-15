//
//  ChatMessage+CoreDataProperties.swift
//  MimicMe
//
//  Created by Full Name on 3/15/18.
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

}
