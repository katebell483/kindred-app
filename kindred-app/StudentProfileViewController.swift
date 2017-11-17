//
//  StudentProfileViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/16/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class StudentProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var studentInfo: UIView!
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var deviceCountLabel: UILabel!
    @IBOutlet weak var studentIconView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellReuseIdentifier = "DeviceCell"

    var studentName:String = "";
    var deviceCount:String = "";
    
    var deviceList = [Device]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentNameLabel.text = self.studentName
        deviceCountLabel.text = self.deviceCount
        studentIconView.backgroundColor = UIColor.blue

        print(self.studentName)
        print(self.deviceCount)
        
        loadDevices()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell:DeviceCollectionCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! DeviceCollectionCell
        
        let device = deviceList[indexPath.row]
        
        cell.deviceMsg.text = device.device_msg

        return cell
    }

    
    struct Device: Codable {
        let device_uuid: String
        let device_msg: String
        let device_label: String
        let device_icon: String
    }
    
    private func loadDevices() {
        
        //Implementing URLSession
        let urlString = "http://127.0.0.1:5000/devices/" + self.studentName
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //Implement JSON decoding and parsing
            do {
                
                //Decode retrived data with JSONDecoder and assing type of Article object
                let deviceData = try JSONDecoder().decode([Device].self, from: data)
                print(deviceData)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.deviceList = deviceData
                    self.collectionView.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
        
        
        //End implementing URLSession
        
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
