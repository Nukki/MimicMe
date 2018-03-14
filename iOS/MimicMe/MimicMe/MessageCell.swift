//
//  MessageCell.swift
//  MimicMe
//
//  Created by Full Name on 3/4/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit
import CoreData

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    func setMessage(msg: String) {
        messageText.text = msg
    }
    
    

}
