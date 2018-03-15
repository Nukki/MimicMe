//
//  MessageCell.swift
//  MimicMe
//
//  Created by Full Name on 3/4/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit
import CoreData

class MessageCell: UICollectionViewCell {
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
//        label.contentMode = .center
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureViews() {
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let centerV = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: messageLabel.superview, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let snapRight = NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: messageLabel.superview, attribute: .trailing, multiplier: 1, constant: 0)
        let snapLeft = NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: messageLabel.superview, attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(centerV)
        addConstraint(snapRight)
        addConstraint(snapLeft)
    }
    
}
