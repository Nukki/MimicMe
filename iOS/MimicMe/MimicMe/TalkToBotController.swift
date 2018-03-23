//
//  TalkToBotController.swift
//  MimicMe
//
//  Created by Full Name on 3/15/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit
import CoreData
import Starscream

private let reuseIdentifier = "Cell"

class TalkToBotController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var messages = [ChatMessage]()
    var socket = WebSocket(url: URL(string: "ws://127.0.0.1:8000/socket")!)
//    var request = URLRequest(url: URL(string: "ws://localhost:5000/")!)
//    var socket: WebSocket?
    
    
    //positioning input window at the bottom
    var bottomConstraint: NSLayoutConstraint?
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
        button.setTitle("Send", for: UIControlState())
        button.backgroundColor = UIColor.purple
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return button
    }()
    
    func sendTapped() {
        let messageContent = typingField.text
        
        // send over socket
        let messageDictionary : [String: String] = [ "message": messageContent! ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            socket.write(string: jsonString)
        } catch let err {
            print(err)
        }
        
        typingField.text = nil           // clear text field
        saveMessage(text: messageContent!, isSender: true)
    }
    
    deinit {   // close socket when view is not active
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages = loadMessagesFromMemory()
        collectionView?.reloadData()
        
//        request.httpMethod = "POST"
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
        // set up the socket
        socket.disableSSLCertValidation = true
        socket.delegate = self
        socket.connect()

        // Register my custom cell class
        self.collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        // LAYOUT -------------------------------------------------------------------------------------
        self.navigationController?.isNavigationBarHidden = false
        collectionView?.backgroundColor = UIColor.init(red: 65.0/255, green: 0.0/255, blue: 129.0/255, alpha: 1.0)
        collectionView?.alwaysBounceVertical = true
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        
        typingContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typingContainerView)
        heightConstraint = NSLayoutConstraint(item: typingContainerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        snapContainerRight = NSLayoutConstraint(item: typingContainerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        snapContainerLeft = NSLayoutConstraint(item: typingContainerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: typingContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(heightConstraint!)
        view.addConstraint(snapContainerRight!)
        view.addConstraint(snapContainerLeft!)
        view.addConstraint(bottomConstraint!)
        configureTypingView()
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
        let topHeight = NSLayoutConstraint(item: topBorderView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 5)

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
        super.viewWillAppear(animated)
        collectionView?.reloadData()
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
        cell.messageLabel.text = chatMessage.text
        if chatMessage.isSender {
            cell.backgroundColor = UIColor.cyan
        } else {
            cell.backgroundColor = UIColor.red
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width,height: 50)
    }
    
    
    // retieve data from memory ( fills messages array)-----------------------------------------------
    func loadMessagesFromMemory() -> [ChatMessage] {
        let fetchRequest: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
        do {
             let chatLog = try PersistenceService.context.fetch(fetchRequest)
             return chatLog
        } catch let err {
            print(err)
        }
        return []
    }
   
}
