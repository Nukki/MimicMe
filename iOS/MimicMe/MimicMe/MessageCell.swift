//
//  MessageCell.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/4/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit
import CoreData

// Chat message cell. (a bubble)
class MessageCell: UICollectionViewCell {
    let messageTextLabel: UITextView = {
        let textLabel = UITextView()
        textLabel.textColor = UIColor.darkGray
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = UIColor.black
        return textLabel
    }()
    
    let bubble: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = UIColor.clear
        view.text = "lol"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        return view
    }()
    
//    let metaView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.green
//        return view
//    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = UIColor.cyan
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureViews() {
//        addSubview(metaView)
        addSubview(nameLabel)
        addSubview(bubble)
        addSubview(messageTextLabel)
    }
    
}
