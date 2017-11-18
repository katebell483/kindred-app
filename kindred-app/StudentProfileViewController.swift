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
    
    // COLLECTION OF DEVICE VIEW
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addDeviceCollectionCell: UICollectionViewCell!
    
    // ADD DEVICE VIEW
    @IBOutlet weak var addDeviceView: UIView!
    @IBOutlet weak var addDeviceLabel: UITextField!
    @IBOutlet weak var addDeviceMessage: UITextField!
    @IBOutlet weak var addDeviceUUID: UITextField!
    @IBOutlet weak var addDeviceButton: UIButton!
    
    @IBOutlet weak var addDeviceIconButton: UIButton!
    
    @IBAction func changeIcon(_ sender: Any) {
        let iconView = self.storyboard?.instantiateViewController(withIdentifier: "icons") as! IconCollectionViewController
        self.present(iconView, animated: true, completion: nil)
    }
    
    let cellReuseIdentifier = "DeviceCell"
    let deviceAddCellIdentifier = "DeviceAddCell"

    var studentName:String = "";
    var deviceCount:String = "";
    
    var deviceList = [Device]()
    
    // send the post request
    @IBAction func addDeviceButton(_ sender: Any) {
        // send post request
        addDevice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the add device view on default
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
        return deviceList.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row == deviceList.count) {
            let cell:DeviceAddCollectionCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: deviceAddCellIdentifier, for: indexPath as IndexPath) as! DeviceAddCollectionCell
            return cell
        }
        
        let cell:DeviceCollectionCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! DeviceCollectionCell
            
        let device = deviceList[indexPath.row]
            
        let icon: UIImage = UIImage(named: device.device_icon)!
        cell.deviceIcon.image = icon
        cell.deviceLabel.text = device.device_label
        cell.deviceUUID.text = device.device_uuid
        cell.deviceMsg.text = device.device_msg
        
        return cell
        
    }

    // detect touch of addition
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == deviceList.count {
            addDeviceButton.setTitle("add device", for: .normal)
            addDeviceIconButton.setImage(nil, for: .normal);
            addDeviceLabel.text = nil;
            addDeviceMessage.text = nil;
            addDeviceUUID.text = nil;
            addDeviceView.isHidden = false
        } else {
            let cell:DeviceCollectionCell = collectionView.cellForItem(at: indexPath) as! DeviceCollectionCell;

            addDeviceButton.setTitle("update device", for: .normal)
            // TODO: hook up the other cells and learn to store data behind scenes
            addDeviceLabel.text = cell.deviceLabel.text;
            addDeviceMessage.text = cell.deviceLabel.text;
            addDeviceUUID.text = cell.deviceUUID.text;
            addDeviceIconButton.setImage(cell.deviceIcon.image, for: .normal);
            
            addDeviceView.isHidden = false
        }
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
    
    func addDevice() {
        // send post request
        
        // if successful then add device to list and update the collection view
        let newDevice = Device(device_uuid: "212323-123", device_msg: "Bathroom npw", device_label: "bathroom", device_icon: "icon.png")

        self.deviceList.append(newDevice)
        
        self.collectionView.reloadData()
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
