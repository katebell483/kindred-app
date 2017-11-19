//
//  StudentProfileViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/16/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit

class StudentProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // STUDENT INFO: TOP SECTION VIEW
    @IBOutlet weak var studentInfo: UIView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var deviceCountLabel: UILabel!
    @IBOutlet weak var studentNameTextInput: UITextField!
    @IBOutlet weak var studentIconView: UIView!
    
    // student enter
    @IBAction func newStudentNameEntered(_ sender: Any) {
        print("NAME ENTERED")
        self.studentName = studentNameTextInput.text!
        studentNameTextInput.isHidden = true
        studentNameLabel.text = self.studentName
        studentNameLabel.isHidden = false
    }
    
    // COLLECTION OF DEVICE VIEW
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    @IBOutlet weak var addDeviceCollectionCell: UICollectionViewCell!
    
    // ADD DEVICE VIEW
    @IBOutlet weak var addDeviceView: UIView!
    @IBOutlet weak var addDeviceLabel: UITextField!
    @IBOutlet weak var addDeviceMessage: UITextField!
    @IBOutlet weak var addDeviceUUID: UITextField!
    @IBOutlet weak var addDeviceButton: UIButton!
    @IBOutlet weak var addDeviceIconButton: UIButton!
    @IBOutlet weak var addDeviceIconLabel: UILabel!
    @IBOutlet weak var deleteDeviceButton: UIButton!
    
    // ICON VIEW
    @IBOutlet weak var iconView: UICollectionView!
    var icons = [UIImage(named:"airplane")!,
                UIImage(named:"toilet-paper")!,
                UIImage(named:"water")!,
                UIImage(named:"leaf")!,
                UIImage(named:"lily-1")!,
                UIImage(named:"alarm-clock")!,
                UIImage(named: "breakfast")!,
                UIImage(named: "dinner")!,
                UIImage(named: "improvement")!,
                UIImage(named: "list")!,
                UIImage(named: "cosmetics")!,
                UIImage(named:"customer-problem")!]
    
    var iconLabels = ["airplane", "toilet-paper", "water", "leaf","lily-1","alarm-clock","breakfast","dinner","improvement","list","cosmetics","customer-problem"]
    
    @IBAction func changeIcon(_ sender: Any) {
        studentInfo.isHidden = true
        addDeviceView.isHidden = true
        deviceCollectionView.isHidden = true
        iconView.isHidden = false
    }
    
    let cellReuseIdentifier = "DeviceCell"
    let deviceAddCellIdentifier = "DeviceAddCell"
    let iconReuseIdentifier = "IconCell"

    var studentName:String = "";
    var deviceCount:String = "";
    var keepAddDeviceOpen:Bool = false;
    var currDevice:Device? = nil;
    
    var deviceList = [Device]()
    
    // send the post request
    @IBAction func addDeviceButton(_ sender: Any) {
        // send post request
        addDevice()
    }
    
    // send the delete request
    @IBAction func deleteDeviceButton(_ sender: Any) {
        deleteDevice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the add device view on default
        iconView.isHidden = true
        addDeviceView.isHidden = true
        
        // is this a new student?
        if(self.studentName.isEmpty) {
            studentNameTextInput.isHidden = false
            studentNameLabel.isHidden = true
            self.deviceCount = "0"
        } else {
            studentNameTextInput.isHidden = true
            studentNameLabel.isHidden = false
            studentNameLabel.text = self.studentName
        }

        deviceCountLabel.text = self.deviceCount + " devices connected"
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
        if collectionView == deviceCollectionView {
            return deviceList.count + 1
        } else {
            return icons.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == deviceCollectionView {
        
            if(indexPath.row == deviceList.count) {
                let cell:DeviceAddCollectionCell = self.deviceCollectionView.dequeueReusableCell(withReuseIdentifier: deviceAddCellIdentifier, for: indexPath as IndexPath) as! DeviceAddCollectionCell
                return cell
            }
            
            let cell:DeviceCollectionCell = self.deviceCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! DeviceCollectionCell
            
            let device = deviceList[indexPath.row]
            
            let icon: UIImage = UIImage(named: device.device_icon)!
            cell.deviceIcon.image = icon
            cell.deviceLabel.text = device.device_label
            cell.deviceUUID.text = device.device_uuid
            cell.deviceMsg.text = device.device_msg
            cell.deviceIconLabel.text = device.device_icon
            
            return cell
        } else {
            let cell:IconCollectionCell = iconView.dequeueReusableCell(withReuseIdentifier: iconReuseIdentifier, for: indexPath as IndexPath) as! IconCollectionCell
            
            cell.iconLabel.text = iconLabels[indexPath.row]
            cell.iconImage.image = icons[indexPath.row]
            
            return cell
        }
        
    }

    // detect touch of addition
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == deviceCollectionView {
            if indexPath.row == deviceList.count {
                addDeviceButton.setTitle("add device", for: .normal)
                deleteDeviceButton.isHidden = true;
                addDeviceIconButton.setImage(nil, for: .normal);
                addDeviceLabel.text = nil;
                addDeviceMessage.text = nil;
                addDeviceUUID.text = nil;
                addDeviceIconLabel.text = nil;
                addDeviceView.isHidden = false
            } else {
                let cell:DeviceCollectionCell = collectionView.cellForItem(at: indexPath) as! DeviceCollectionCell;

                addDeviceButton.setTitle("update device", for: .normal)
                deleteDeviceButton.isHidden = false;
                addDeviceLabel.text = cell.deviceLabel.text;
                addDeviceMessage.text = cell.deviceLabel.text;
                addDeviceUUID.text = cell.deviceUUID.text;
                addDeviceIconLabel.text = cell.deviceIconLabel.text;
                addDeviceIconButton.setImage(cell.deviceIcon.image, for: .normal);
                
                addDeviceView.isHidden = false
            }
        } else {
            let cell:IconCollectionCell = collectionView.cellForItem(at: indexPath) as! IconCollectionCell;
            addDeviceIconButton.setImage(cell.iconImage.image, for: .normal);
            addDeviceIconLabel.text = cell.iconLabel.text
            studentInfo.isHidden = false
            addDeviceView.isHidden = false
            deviceCollectionView.isHidden = false
            iconView.isHidden = true
        }
        
    }
    
    private func loadDevices() {
        
        //Implementing URLSession
        let urlString = "https://kindred-web.herokuapp.com/devices/" + self.studentName
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
                    self.deviceCollectionView.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
        
        
        //End implementing URLSession
        
    }
    
    func addDevice() {
        //Implementing URLSession
        let urlString = "https://kindred-web.herokuapp.com/device"
        guard let url = URL(string: urlString) else { return }
        
        let postData: [String: String] = [
            "student_name": studentNameLabel.text!,
            "device_uuid": addDeviceUUID.text!,
            "device_label": addDeviceLabel.text!,
            "device_msg": addDeviceMessage.text!,
            "device_icon": addDeviceIconLabel.text!
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postData, options: .prettyPrinted)
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("UH PH")
                print(error!.localizedDescription)
                // TODO something on error
            }
            
            print("SDFDFDF")
            
        }.resume()
        
        let newDevice = Device(device_uuid: addDeviceUUID.text!, device_msg: addDeviceMessage.text!, device_label: addDeviceLabel.text!, device_icon: addDeviceIconLabel.text!)
        
        self.deviceList.append(newDevice)
        
        self.deviceCollectionView.reloadData()
        deviceCountLabel.text = String(self.deviceList.count) + " devices connected"
        addDeviceView.isHidden = true
    }

    func deleteDevice() {
        let urlString = "https://kindred-web.herokuapp.com/device/" + addDeviceUUID.text!
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                // TODO something on error
            }
            
        }.resume()
        
        for (idx, device) in deviceList.enumerated() {
            if device.device_uuid == addDeviceUUID.text {
                deviceList.remove(at: idx)
            }
        }
        
        self.deviceCollectionView.reloadData()
        deviceCountLabel.text = String(self.deviceList.count) + " devices connected"
        addDeviceView.isHidden = true
        
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
