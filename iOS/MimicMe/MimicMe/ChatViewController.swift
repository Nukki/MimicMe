////
////  ChatViewController.swift
////  MimicMe
////
////  Created by Full Name on 2/27/18.
////  Copyright © 2018 N. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class ChatViewController : UIViewController {
////class ChatViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
//
//    @IBOutlet weak var tableView: UITableView!
//    
//    var messages: [String] = []
//    
//    override func viewDidLoad(){
//        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = false
//        navigationController?.navigationBar.barTintColor = UIColor.purple
//        messages = createMessages()
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        tableView.estimatedRowHeight = UITableViewAutomaticDimension
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 100
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = true
//    }
//    
//    func createMessages() -> [String] {
//        var moreMessages: [String] = []
//        moreMessages.append("heyy")
//        moreMessages.append("sup")
//        moreMessages.append("u there? u there? u there? here? u there??")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("just wondering if this message is gonna be cut off at all")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("just wondering if this message is gonna be cut off at all")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("u hear me?")
//        moreMessages.append("just wondering if this message is gonna be cut off at all")
//        moreMessages.append("u hear me?")
//        return moreMessages
//    }
//}
//
//extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let msg = messages[indexPath.row]
//        
//        //configure cell
////        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
////
//////        cell.layer.cornerRadius = cell.frame.height / 2
//        
////        cell.setMessage(msg: msg)
//        
//        // make bubble
//        let size = CGSize(width: 250.0, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//        let estimatedFrame = NSString(string: msg).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
//
//        cell.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 16)
//
//        cell.messageText.frame = CGRect(x: 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 16)
//        cell.bubbleView.frame = CGRect(x: 0, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 16)
//        cell.bubbleView.layer.cornerRadius = 10
//        cell.bubbleView.layer.masksToBounds = true
//
//        
//        return cell
//    }
//    
//    
//        
//}

