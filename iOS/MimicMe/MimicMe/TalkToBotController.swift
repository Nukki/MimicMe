//
//  TalkToBotController.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/15/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit
import CoreData
import Starscream

private let reuseIdentifier = "Cell"

class TalkToBotController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var room: Room? { // gets room from navigation controller (pushed by MainView)
    didSet {
       navigationItem.title = room?.name
     }
    }
    
    var messages = [ChatMessage]() // messages from core data
    
    var socket = WebSocket(url: URL(string: "ws://127.0.0.1:8000/chat/stream/")!)
//    var socket = WebSocket(url: URL(string: "ws://192.168.0.2:8000/socket")!)
    
    // positioning input window at the bottom
    var bottomConstraint: NSLayoutConstraint?
    var bottomContraintMainView: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var snapContainerRight: NSLayoutConstraint?
    var snapContainerLeft: NSLayoutConstraint?
    
    // create a container to hold input and send button at the bottom
    let typingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        return view
    }()
    
    // user input happens here
    let typingField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Say hello"
        textField.backgroundColor = UIColor.white
        return textField
    }()
    
    // initialize send button
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return button
    }()
    
    // send button was tapped
    func sendTapped() {
        let messageContent = typingField.text
        
        // write to socket
        // commands: join, leave send  // "command"
//        data has message, type, username ??????????
        let messageDictionary : [String: String] = [ "message": messageContent! ]
//        let messageDictionary : [String: String] = [ "command": "send" , "message": messageContent! ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            socket.write(string: jsonString)
        } catch let err {
            print(err)
        }
        typingField.resignFirstResponder()
        typingField.text = nil           // clear text field
        saveMessage(text: messageContent!, isSender: true, room: room!)
    }
    
    deinit {   // close socket when view is not active
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages = loadMessagesFromMemory()
        collectionView?.reloadData()
        
        // set up the socket
        socket.disableSSLCertValidation = true
        socket.delegate = self
        socket.connect()

        // Register my custom cell class
        self.collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        // LAYOUT -------------------------------------------------------------------------------------
        collectionView?.contentInset = UIEdgeInsetsMake(0.0,0.0,58.0,0.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        self.navigationController?.isNavigationBarHidden = false
        collectionView?.backgroundColor = UIColor.init(red: 65.0/255, green: 0.0/255, blue: 129.0/255, alpha: 1.0)
        collectionView?.alwaysBounceVertical = true
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        
        typingContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typingContainerView)
        heightConstraint = NSLayoutConstraint(item: typingContainerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50)
        snapContainerRight = NSLayoutConstraint(item: typingContainerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        snapContainerLeft = NSLayoutConstraint(item: typingContainerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: typingContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraint(heightConstraint!)
        view.addConstraint(snapContainerRight!)
        view.addConstraint(snapContainerLeft!)
        view.addConstraint(bottomConstraint!)
        configureTypingView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // animates input field up when keyboard appears
    func handleKeyboardNotification(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let isKeyBoardShowing = notification.name ==  NSNotification.Name.UIKeyboardWillShow
            bottomConstraint?.constant = isKeyBoardShowing ? -keyboardHeight : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if !self.messages.isEmpty && isKeyBoardShowing {
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    private func configureTypingView() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor.black
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        typingField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        typingContainerView.addSubview(typingField)
        typingContainerView.addSubview(sendButton)
        typingContainerView.addSubview(topBorderView)
        
        // center vertically
        let centerButtonV = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: typingContainerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let centerInputV = NSLayoutConstraint(item: typingField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: typingContainerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        
        // center horizontally
        let centerTopH = NSLayoutConstraint(item: topBorderView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: typingContainerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        
        // attach topview to top of container and make height 5
        let topSnap = NSLayoutConstraint(item: topBorderView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: typingContainerView, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 0.0)
        let topHeight = NSLayoutConstraint(item: topBorderView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 3)

        // typing input and button share width
        let snapInputLeft = NSLayoutConstraint(item: typingField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: typingContainerView, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1.0, constant: 8.0)
        let snapButtonRight = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: typingContainerView, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1.0, constant: 8.0)
        
        let buttonWidth = NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        
        let spaceBtwInputAndButton = NSLayoutConstraint(item: typingField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: sendButton, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: 8)
        typingContainerView.addConstraint(centerButtonV)
        typingContainerView.addConstraint(centerInputV)
        typingContainerView.addConstraint(centerTopH)
        typingContainerView.addConstraint(topSnap)
        typingContainerView.addConstraint(topHeight)
        typingContainerView.addConstraint(snapInputLeft)
        typingContainerView.addConstraint(snapButtonRight)
        typingContainerView.addConstraint(buttonWidth)
        typingContainerView.addConstraint(spaceBtwInputAndButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        collectionView?.reloadData()
        // automatically scroll to bottom
        if !self.messages.isEmpty {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // automatically scroll to bottom
        if !self.messages.isEmpty {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }

    // Hide navigation bar upon exit
    override func viewWillDisappear(_ animated: Bool) {
        socket.disconnect()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // hide keyboard when click anywhere outside input field
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        typingField.endEditing(true)
    }
    
    



    // MARK: UICollectionViewDataSource -------------------------------------------------------------------------------------------

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chatMessage = messages[indexPath.item] as ChatMessage
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
    
        // Configure the cell
        cell.messageTextLabel.text = chatMessage.text
        
        if let messageText =  chatMessage.text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
            
            // adjust color and position of message bubble
            // depending if it's a sender message or a message from other users
            if chatMessage.isSender {
                cell.messageTextLabel.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 2 - 3 , y: 0, width: estimatedFrame.width + 16 , height: estimatedFrame.height + 18)
                cell.bubble.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 3, y: 0, width: estimatedFrame.width + 16 + 8  , height: estimatedFrame.height + 18)
                cell.bubble.backgroundColor = UIColor.init(red: 82/255, green: 51/255, blue: 189/255, alpha: 1.0)
                cell.messageTextLabel.textColor = UIColor.white
            } else {
                cell.messageTextLabel.frame = CGRect(x: 8, y: 0, width: estimatedFrame.width + 16 , height: estimatedFrame.height + 18)
                cell.bubble.frame = CGRect(x: 3, y: 0, width: estimatedFrame.width + 16 + 8  , height: estimatedFrame.height + 18)
                cell.bubble.backgroundColor =  UIColor(white: 0.95, alpha: 1)
                cell.messageTextLabel.textColor = UIColor.black
            }
        }
        return cell
    }
    
    // helps the dynamic height of message cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let messageText =  messages[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 18)
        }
        return CGSize(width: view.frame.width,height: 100)
    }
}
