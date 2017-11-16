//
//  StudentProfileViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/16/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class StudentProfileViewController: UIViewController {

    @IBOutlet weak var studentInfo: UIView!
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var deviceCountLabel: UILabel!
    
    var studentName:String = "";
    var deviceCount:String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentNameLabel.text = self.studentName
        deviceCountLabel.text = self.deviceCount
        print(self.studentName)
        print(self.deviceCount)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
