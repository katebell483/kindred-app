//
//  ViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/8/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    
    var students = [Student]()
    
    // These are the colors of the square views in our table view cells.
    // In a real project you might use UIImages.
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSampleStudents()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:StudentCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! StudentCell
        
        let student = students[indexPath.row]
        
        cell.myView.backgroundColor = self.colors[indexPath.row]
        cell.studentName.text = student.name;
        cell.deviceCount.text = String(student.devices.count);
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    private func loadSampleStudents() {
        
        let device = Device(id: 0, studentId: 1, uuid: "111-222", label: "bathroom", message: "go to the bathroom", icon: "icon.png")
        
        guard let student1 = Student(name: "kate", devices: [device!]) else {
            fatalError("Unable to instantiate meal2")
        }
        
        students += [student1]
    }

}

