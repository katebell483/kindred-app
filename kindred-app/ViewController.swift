//
//  ViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/8/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var studentList = [StudentInfo]()
    
    // These are the colors of the square views in our table view cells.
    // In a real project you might use UIImages.
    let colors = [UIColor.blue, UIColor.yellow, UIColor.magenta, UIColor.red, UIColor.brown]
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadStudentList()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:StudentCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! StudentCell
        
        let student = studentList[indexPath.row]
        
        print(student.student_name)
        
        var colorIndex:Int = 0;
        if indexPath.row < self.colors.count {
            colorIndex = indexPath.row
        } else {
            colorIndex = indexPath.row % self.colors.count
        }
        
        cell.myView.backgroundColor = self.colors[colorIndex]
        cell.studentName.text = student.student_name;
        cell.deviceCount.text = String(student.device_count);
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:StudentCell = tableView.cellForRow(at: indexPath) as! StudentCell;
        let name:String = cell.studentName.text!
        let deviceNumber:String = cell.deviceCount.text!;

        let studentProfileView = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! StudentProfileViewController
        
        studentProfileView.studentName = name
        studentProfileView.deviceCount = deviceNumber

        self.present(studentProfileView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }

    struct StudentInfo: Codable {
        let student_name: String
        let device_count: Int
    }

    private func loadStudentList() {
        
        //Implementing URLSession
        let urlString = "http://127.0.0.1:5000/studentList"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                //Decode retrived data with JSONDecoder and assing type of Article object
                let studentData = try JSONDecoder().decode([StudentInfo].self, from: data)
                print(studentData)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.studentList = studentData
                    self.tableView.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
        
        
        //End implementing URLSession
        
    }

}

