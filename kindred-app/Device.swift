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
    
    var id: Int
    var studentId: Int
    var uuid: String
    var label: String
    var message: String
    var icon: String
    
    init?(id: Int, studentId: Int, uuid: String, label: String, message: String, icon: String) {
        
        // Initialization should fail if there is no name or if the rating is negative.
        if id < 0 || studentId < 0 || uuid.isEmpty || uuid.isEmpty || label.isEmpty || message.isEmpty || icon.isEmpty {
            return nil
        }
        
        // Initialize stored properties.
        self.id = id
        self.studentId = studentId
        self.uuid = uuid
        self.label = label
        self.message = message
        self.icon = icon
    }
    
}
