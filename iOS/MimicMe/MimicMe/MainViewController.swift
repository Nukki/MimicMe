//
//  MainViewController.swift
//  MimicMe
//
//  Created by Nikki Jack on 3/1/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import PKHUD

class MainViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var rooms = [Room]() // data for rooms table
    var jsonArr: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55;
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        HUD.show(.progress)
        rooms = getRoomsFromServer() // get data to fill the table every time the view appears
        tableView.reloadData()
    }
    
    // ******************* TableView setup ******************************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.item] as Room
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.backgroundColor = UIColor.init(red: 96.0/255, green: 49.0/255, blue: 152.0/255, alpha: 1.0)
        cell.textLabel?.text = room.name
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = TalkToBotController(collectionViewLayout: layout)
        let room = rooms[indexPath.item] as Room
        controller.room = room
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // *********************** Buttons Actions ******************************
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "secret")
        self.dismiss(animated: false, completion: nil)
        self.performSegue(withIdentifier: "letmein", sender: self)
    }
} // end MainViewController

// struct for parsing JSON to Room
struct RoomFromJson: Decodable {
    let id: Int32
    let name: String
}



