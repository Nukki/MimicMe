//
//  MainViewController.swift
//  MimicMe
//
//  Created by Full Name on 3/1/18.
//  Copyright © 2018 N. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    var user = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // if not logged in, go to login/signup (UnknownUser View)
        if user == false {
             self.performSegue(withIdentifier: "letmein", sender: self)
        }
        else {
            print("LOGGED IN")
        }

        
    }
    
}
