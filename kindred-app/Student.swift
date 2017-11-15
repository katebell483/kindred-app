//
//  Student.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/15/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class Student {
    
    //MARK: Properties
    
    var name: String
    var devices: [Device]
    
    init?(name: String, devices: [Device]) {

        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty  {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.devices = devices
    }
    
}
