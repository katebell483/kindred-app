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
    var colors = [UIColor]()
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var addStudentButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let blue1:UIColor = UIColor.init(red: 47, green: 112, blue: 255, alpha: 1)
        
        let blue1 = UIColor.init(red: 186/255, green: 209/255, blue: 196/255, alpha: 1);
        let blue2 = UIColor.init(red: 114/255, green: 137/255, blue: 141/255, alpha: 1);
        let blue3 = UIColor.init(red: 71/255, green: 90/255, blue: 106/255, alpha: 1);
        let blue4 = UIColor.init(red: 43/255, green: 50/255, blue: 72/255, alpha: 1);
        
        colors.append(blue1)
        colors.append(blue2)
        colors.append(blue3)
        colors.append(blue4)
        
        self.loadStyles()
        self.loadStudentList()
    }
    
    func loadStyles() {
        // add student button
        addStudentButton.layer.cornerRadius = 30
        addStudentButton.backgroundColor = colors[2]
        addStudentButton.layer.shadowColor = UIColor.gray.cgColor
        addStudentButton.layer.shadowOpacity = 0.3
        addStudentButton.layer.shadowRadius = 6
        addStudentButton.layer.shadowOffset.width = 1
        addStudentButton.layer.shadowOffset.height = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:StudentCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! StudentCell
        
        let student = studentList[indexPath.row]
        
        var colorIndex:Int = 0;
        if indexPath.row < self.colors.count {
            colorIndex = indexPath.row
        } else {
            colorIndex = indexPath.row % self.colors.count
        }
        
        cell.studentInitialBackground.backgroundColor = self.colors[colorIndex]
        cell.studentInitialBackground.layer.cornerRadius = 10
        
        cell.studentInitialBackground.layer.shadowColor = UIColor.gray.cgColor
        cell.studentInitialBackground.layer.shadowOpacity = 0.3
        cell.studentInitialBackground.layer.shadowRadius = 6
        cell.studentInitialBackground.layer.shadowOffset.width = 2
        cell.studentInitialBackground.layer.shadowOffset.height = 2
 
        cell.studentName.text = student.student_name;
        cell.deviceCount.text = String(student.device_count)
        cell.deviceCountDescriptor.text = "Devices Connected"
        let index = student.student_name.index(student.student_name.startIndex, offsetBy: 1)
        cell.studentInitials.text = String(student.student_name.prefix(upTo: index))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:StudentCell = tableView.cellForRow(at: indexPath) as! StudentCell;
        let name:String = cell.studentName.text!
        let deviceNumber:String = cell.deviceCount.text!;

        let studentProfileView = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! StudentProfileViewController
        
        studentProfileView.studentName = name
        studentProfileView.deviceCountNum = deviceNumber
        
        var colorIndex:Int = 0;
        if indexPath.row < self.colors.count {
            colorIndex = indexPath.row
        } else {
            colorIndex = indexPath.row % self.colors.count
        }
    
        studentProfileView.iconColor = colors[colorIndex]

        self.present(studentProfileView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let cell:StudentCell = tableView.cellForRow(at: indexPath) as! StudentCell;
            deleteStudent(studentName: cell.studentName.text!)
            print("DELETE STUDENT")
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    struct StudentInfo: Codable {
        let student_name: String
        let device_count: Int
    }

    private func loadStudentList() {
        
        //Implementing URLSession
        let urlString = "https://kindred-web.herokuapp.com/studentList"
        //let urlString = "https://127.0.0.1:8000/studentList"

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
    
    private func deleteStudent(studentName: String) {
        let urlString = "https://kindred-web.herokuapp.com/student/" + studentName.lowercased()
        //let urlString = "https://127.0.0.1:8000/student/" + studentName
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                // TODO something on error
            }
            
            }.resume()
        
        for (idx, student) in studentList.enumerated() {
            if student.student_name == studentName {
                studentList.remove(at: idx)
            }
        }
        
        self.tableView.reloadData()
    }

}

