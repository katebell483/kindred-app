//
//  Device.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/15/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class Device {
    
    //MARK: Properties
    var device_uuid: String
    var device_msg: String
    var device_label: String
    var device_icon: String
    
    init?(device_uuid: String, device_msg: String, device_label: String, device_icon: String) {
        
        // Initialization should fail if there is no name or if the rating is negative.
        if device_uuid.isEmpty || device_msg.isEmpty || device_label.isEmpty || device_icon.isEmpty {
            return nil
        }
        
        // Initialize stored properties.
        self.device_uuid = device_uuid
        self.device_msg = device_msg
        self.device_label = device_label
        self.device_icon = device_icon

    }
    
}
