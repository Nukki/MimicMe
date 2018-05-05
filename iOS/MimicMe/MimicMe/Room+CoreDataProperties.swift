//
//  Room+CoreDataProperties.swift
//  MimicMe
//
//  Created by Nikki Jack on 5/4/18.
//  Copyright © 2018 N. All rights reserved.
//
//

import Foundation
import CoreData


extension Room {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Room {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: ChatMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: ChatMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
