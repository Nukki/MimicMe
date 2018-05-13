//
//  CreateRoomViewController.swift
//  MimicMe
//
//  Created by Nikki Jack on 5/4/18.
//  Copyright © 2018 N. All rights reserved.
//

import UIKit
import PKHUD

class CreateRoomViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate,
    UITableViewDataSource {
    
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var bots = [Bot]()          // bot data to fill the table (from server)
    var chosenBots = [String]() // array of string IDs of rooms that the user chose to add to room
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress)
        bots = getBotListFromServer()
        bots = [Bot(name: "Tensorflow-dataset2", id: "0"), Bot(name: "Tensorflow-dataset1", id: "1")]
        roomNameTextField.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55;
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        navigationController?.navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }
    
    // Called when 'Done' key pressed (keyboard disappears)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Hide navigation bar upon exit
    override func viewWillDisappear(_ animated: Bool) {
        roomNameTextField.resignFirstResponder()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    // *********************** Bot TableView Setup *****************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bot = bots[indexPath.item] as Bot
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.backgroundColor = UIColor.init(red: 104.0/255, green: 60.0/255, blue: 157.0/255, alpha: 1.0)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = bot.name
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("-------------------------------------------")
        let bot = bots[indexPath.item] as Bot
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            // row unselected
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            chosenBots.remove(at: chosenBots.index(of: bot.id)!)
            print("unselected bot id ", bot.id)
        } else {
            // row selected
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            chosenBots.append(bot.id) // add the id to chosen bot list
            print("selected bot id ", bot.id)
        }
        print("Current chosen bot list: ", chosenBots)
    }
    
    // ********** Button Actions ***********************
    
    @IBAction func goTapped(_ sender: UIButton) {
        let roomName = roomNameTextField.text!
        roomNameTextField.resignFirstResponder()
        
        // validate user input
        if roomName.isEmpty {
            displayAlertMessage("Room name should not be empty")
            return
        }
        let botList = !chosenBots.isEmpty ? chosenBots.joined(separator: " ") : ""
        print("Going to send bot id list: ", botList)
        HUD.show(.progress)
        sendToServer(roomName: roomName, bots: botList)
    } // end goTapped
} // end controller

