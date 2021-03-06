//
//  StudentProfileViewController.swift
//  kindred-app2
//
//  Created by Katherine Bell on 11/16/17.
//  Copyright © 2017 Katherine Bell. All rights reserved.
//

import UIKit
import TesseractOCR

extension UITextField {
    open override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 3.0
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        let text:String = self.placeholder!;
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        self.layer.masksToBounds = true
    }
}

class StudentProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {

    // STUDENT INFO: TOP SECTION VIEW
    @IBOutlet weak var studentInfo: UIView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var deviceCountDescriptor: UILabel!
    @IBOutlet weak var deviceCount: UILabel!
    @IBOutlet weak var studentNameTextInput: UITextField!
    @IBOutlet weak var studentInitialsBackground: UIView!
    @IBOutlet weak var studentInitials: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    // student enter
    @IBAction func newStudentNameEntered(_ sender: Any) {
        self.studentName = studentNameTextInput.text!
        if(self.studentName == "") {
            return
        }
        studentNameTextInput.isHidden = true
        studentNameLabel.text = self.studentName.capitalized
        studentNameLabel.isHidden = false
        let index = self.studentName.index(self.studentName.startIndex, offsetBy: 1)
        studentInitials.text = String(self.studentName.prefix(upTo: index)).capitalized
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
    
    // take photo button for text detection
    @IBAction func takePhoto(_ sender: Any) {
        presentImagePicker();
    }
    
    // VAR KEEPING STATE OF KEYBOARD ADJUSTMENT
    var viewAdjustedForKeyboard:Bool = false
    var activeField: UITextField?
    
    @IBAction func addDeviceCloseButton(_ sender: Any) {
        addDeviceView.isHidden = true
    }
    
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
    
    @IBOutlet weak var iconViewPrompt: UILabel!
    @IBOutlet weak var iconViewBackButton: UIButton!
    @IBAction func iconViewBackTrigger(_ sender: Any) {
        toggleIconView()
    }
    
    
    var iconLabels = ["airplane", "toilet-paper", "water", "leaf","lily-1","alarm-clock","breakfast","dinner","improvement","list","cosmetics","customer-problem"]
    

    var iconColor = UIColor.init(red: 186/255, green: 209/255, blue: 196/255, alpha: 1);
    
    @IBAction func changeIcon(_ sender: Any) {
        toggleIconView()
    }
    
    let cellReuseIdentifier = "DeviceCell"
    let deviceAddCellIdentifier = "DeviceAddCell"
    let iconReuseIdentifier = "IconCell"

    var studentName:String = "";
    var deviceCountNum:String = "";
    var keepAddDeviceOpen:Bool = false;
    var currDevice:Device? = nil;
    
    var deviceList = [Device]()
    
    // send the post request
    @IBAction func addDeviceButton(_ sender: Any) {
        // send post request
        addDevice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
        let longPress = UILongPressGestureRecognizer(
            target: self, action: #selector(longPressHandler))
        deviceCollectionView.addGestureRecognizer(longPress)
        
        // hide the add device view on default
        iconView.isHidden = true
        iconViewPrompt.isHidden = true
        iconViewBackButton.isHidden = true
        addDeviceView.isHidden = true
        
        //addDeviceIconButton.layer.borderColor = UIColor.gray as! CGColor;
        
        // add Device Fields
        addDeviceIconButton.layer.borderColor = UIColor.lightGray.cgColor
        addDeviceIconButton.layer.borderWidth = 1.5
        addDeviceIconButton.layer.cornerRadius = 10
        addDeviceIconButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        addDeviceLabel.layer.borderColor = UIColor.lightGray.cgColor
        addDeviceUUID.layer.borderColor = UIColor.lightGray.cgColor
        addDeviceMessage.layer.borderColor = UIColor.lightGray.cgColor
        
        // is this a new student?
        if(self.studentName.isEmpty) {
            studentNameTextInput.isHidden = false
            studentNameLabel.isHidden = true
            self.deviceCountNum = "0"
            studentInitials.text = ""

        } else {
            studentNameTextInput.isHidden = true
            studentNameLabel.isHidden = false
            studentNameLabel.text = self.studentName
            let index = self.studentName.index(self.studentName.startIndex, offsetBy: 1)
            studentInitials.text = String(self.studentName.prefix(upTo: index))
        }

        deviceCountDescriptor.text = "Devices Connected"
        deviceCount.text = self.deviceCountNum
        studentInitialsBackground.backgroundColor = iconColor
        
        studentInitialsBackground.layer.cornerRadius = 10
        studentInitialsBackground.layer.shadowColor = UIColor.gray.cgColor
        studentInitialsBackground.layer.shadowOpacity = 0.3
        studentInitialsBackground.layer.shadowRadius = 6
        studentInitialsBackground.layer.shadowOffset.width = 2
        studentInitialsBackground.layer.shadowOffset.height = 2
        
        self.studentNameTextInput.delegate = self
        self.addDeviceUUID.delegate = self
        self.addDeviceLabel.delegate = self
        self.addDeviceMessage.delegate = self

        loadDevices()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if(activeField != studentNameTextInput) {
            viewAdjustedForKeyboard = true
            var rect:CGRect = self.view.frame;
            rect.origin.y -= 250.0;
            rect.size.height += 250.0;
            self.view.frame = rect;
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if(viewAdjustedForKeyboard) {
            viewAdjustedForKeyboard = false
            var rect:CGRect = self.view.frame;
            rect.origin.y += 250.0;
            rect.size.height -= 250.0;
            self.view.frame = rect;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @objc func longPressHandler(press:UILongPressGestureRecognizer){
        if(press.state == .ended) {
            let point = press.location(in: self.deviceCollectionView)
            let indexPath = self.deviceCollectionView.indexPathForItem(at: point)
            
            if let index = indexPath {
                var cell:DeviceCollectionCell = self.deviceCollectionView.cellForItem(at: index) as! DeviceCollectionCell
                
                let deleteDeviceAlert = UIAlertController(title: "Delete", message: "Delete this device?", preferredStyle: UIAlertControllerStyle.alert)
                
                deleteDeviceAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.deleteDevice(uuid: cell.deviceUUID.text!)
                }))
                
                deleteDeviceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                }))
                
                present(deleteDeviceAlert, animated: true, completion: nil)
                
            } else {
                print("Could not find index path")
            }
        }
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
                
                    // styles for add device button
                    cell.addDeviceBackground.layer.shadowColor = UIColor.gray.cgColor
                    cell.addDeviceBackground.layer.shadowOpacity = 0.3
                    cell.addDeviceBackground.layer.shadowRadius = 6
                    cell.addDeviceBackground.layer.shadowOffset.width = 1
                    cell.addDeviceBackground.layer.shadowOffset.height = 1
                    cell.addDeviceBackground.layer.cornerRadius = 30
                return cell
            }
            
            let cell:DeviceCollectionCell = self.deviceCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath as IndexPath) as! DeviceCollectionCell
            
            let device = deviceList[indexPath.row]
            
            let icon: UIImage = UIImage(named: device.device_icon)!
            cell.deviceIcon.image = icon
            cell.deviceLabel.text = device.device_label.capitalized
            cell.deviceUUID.text = device.device_uuid
            cell.deviceMsg.text = device.device_msg.capitalized
            cell.deviceIconLabel.text = device.device_icon
            
            return cell
        } else {
            let cell:IconCollectionCell = iconView.dequeueReusableCell(withReuseIdentifier: iconReuseIdentifier, for: indexPath as IndexPath) as! IconCollectionCell
            
            cell.iconLabel.text = iconLabels[indexPath.row]
            cell.iconImage.image = icons[indexPath.row]
            
            return cell
        }
        
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        print("longpressed")
    }
    
    // detect touch of addition
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == deviceCollectionView {
            if indexPath.row == deviceList.count {
                addDeviceButton.setTitle("Add Device", for: .normal)
                //deleteDeviceButton.isHidden = true;
                addDeviceIconButton.setImage(nil, for: .normal);
                addDeviceLabel.text = nil;
                addDeviceMessage.text = nil;
                addDeviceUUID.text = nil;
                addDeviceIconLabel.text = nil;
                addDeviceView.isHidden = false
            } else {
                let cell:DeviceCollectionCell = collectionView.cellForItem(at: indexPath) as! DeviceCollectionCell;
                addDeviceButton.setTitle("Update Device", for: .normal)
                //deleteDeviceButton.isHidden = false;
                addDeviceLabel.text = cell.deviceLabel.text;
                addDeviceMessage.text = cell.deviceMsg.text;
                addDeviceUUID.text = cell.deviceUUID.text;
                addDeviceIconLabel.text = cell.deviceIconLabel.text;
                addDeviceIconButton.setImage(cell.deviceIcon.image, for: .normal);
                addDeviceIconButton.imageView?.tintColor = UIColor.black
                addDeviceView.isHidden = false
            }

        } else {
            let cell:IconCollectionCell = collectionView.cellForItem(at: indexPath) as! IconCollectionCell;
            addDeviceIconButton.setImage(cell.iconImage.image, for: .normal);
            addDeviceIconButton.imageView?.tintColor = UIColor.black
            addDeviceIconLabel.text = cell.iconLabel.text
            toggleIconView()
        }
        
    }
    
    func toggleIconView() {
        iconView.isHidden = !iconView.isHidden
        iconViewBackButton.isHidden = !iconViewBackButton.isHidden
        iconViewPrompt.isHidden = !iconViewPrompt.isHidden
        studentInfo.isHidden = !studentInfo.isHidden
        addDeviceView.isHidden = !addDeviceView.isHidden
        deviceCollectionView.isHidden = !deviceCollectionView.isHidden
        backButton.isHidden = !backButton.isHidden
    }
    
    private func loadDevices() {
        
        //Implementing URLSession
        let urlString = "https://kindred-web.herokuapp.com/devices/" + self.studentName.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "%20")
        
        print("URL STRING: " + urlString)

        //let urlString = "https://127.0.0.1:8000/devices" + self.studentName
        guard let url = URL(string: urlString) else { return }
        
        print("URL STRING: " + urlString)
        
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
            "student_name": studentNameLabel.text!.trimmingCharacters(in: .whitespaces),
            "device_uuid": addDeviceUUID.text!.trimmingCharacters(in: .whitespaces),
            "device_label": addDeviceLabel.text!.trimmingCharacters(in: .whitespaces),
            "device_msg": addDeviceMessage.text!.trimmingCharacters(in: .whitespaces),
            "device_icon": addDeviceIconLabel.text!.trimmingCharacters(in: .whitespaces)
        ]
        
        print(postData)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: postData, options: .prettyPrinted)
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                // TODO something on error
            }
            
        }.resume()
        
        if self.deviceList.contains(where: { $0.device_uuid == addDeviceUUID.text! }) {
            // found
            
            var device:Device = self.deviceList.filter{ $0.device_uuid == addDeviceUUID.text! }.first!
            
            device.device_icon = addDeviceIconLabel.text!
            device.device_msg = addDeviceMessage.text!
            device.device_label = addDeviceLabel.text!
            
            let idx = self.deviceList.index(where: { (item) -> Bool in
                item.device_uuid == addDeviceUUID.text!
            })

            self.deviceList[idx!] = device
            
        } else {
            // not
            let newDevice = Device(device_uuid: addDeviceUUID.text!, device_msg: addDeviceMessage.text!, device_label: addDeviceLabel.text!, device_icon: addDeviceIconLabel.text!,student_name: studentNameLabel.text!)
            
            self.deviceList.append(newDevice)
        }

        self.deviceCollectionView.reloadData()
        deviceCount.text = String(self.deviceList.count) 
        deviceCountDescriptor.text = "devices connected"
        addDeviceView.isHidden = true
        
        // reload ble devices
        BluetoothService.shared.updateDevices()
        
    }

    func deleteDevice(uuid: String) {
        print("deleting device")
        let urlString = "https://kindred-web.herokuapp.com/device/" + uuid.trimmingCharacters(in: .whitespaces)
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
            if device.device_uuid == uuid {
                deviceList.remove(at: idx)
            }
        }
        
        self.deviceCollectionView.reloadData()
        deviceCount.text = String(self.deviceList.count)
        
        BluetoothService.shared.updateDevices()
    }

    // Tesseract Image Recognition
    func performImageRecognition(_ image: UIImage) {
        // 1
        if let tesseract = G8Tesseract(language: "eng") {
            // 2
            tesseract.engineMode = .tesseractCubeCombined
            // 3
            tesseract.pageSegmentationMode = .auto
            // 4
            tesseract.image = image.g8_blackAndWhite()
            // 5
            tesseract.recognize()
            // 6
            addDeviceUUID.text = tesseract.recognizedText.trimmingCharacters(in: .whitespaces)
        }
    }

}

// 1
// MARK: - UINavigationControllerDelegate
extension StudentProfileViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension StudentProfileViewController: UIImagePickerControllerDelegate {
    func presentImagePicker() {
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 1
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 2
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        // 3
        present(imagePickerActionSheet, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // 2
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage(640) {
            // 3
            //activityIndicator.startAnimating()
            // 4
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
            })
        }
    }
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
