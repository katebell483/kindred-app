//
//  BLECentralViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 11/29/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class BLEController : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //Data
    var centralManager : CBCentralManager!
    var data = NSMutableData()
    var timer = Timer()
    
    var writeCharacteristic: CBCharacteristic?
    var readCharacteristic: CBCharacteristic?
    var peripheral:CBPeripheral!
    var scanEnabled:Bool = false
    
    // peripheral list
    var peripherals: [CBPeripheral] = []
    
    // devices
    public var allDeviceList = [Device]()
    
    var BLEDevice_UUID:String = "379B5933-F6FC-00BB-AFF4-CF8E1269327B"
    var BLEService_UUID:String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    var BLERead_UUID:String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    var BLEWrite_UUID:String = "6E400002-B5A3-F393-­E0A9-­E50E24DCCA9E"
    
    override init() {
        super.init()
        getAllDevices()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("Bluetooth Enabled")
            scanEnabled = true
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
        }
    }
    
    func startScan() {
        print("Now Scanning...")
        let arrayOfServices: [CBUUID] = [CBUUID(string: BLEService_UUID)]
        centralManager?.scanForPeripherals(withServices: arrayOfServices , options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)])
    }
    
    @objc func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let uuid:UUID = peripheral.identifier;
        
        //if(deviceList.contains { $0.device_uuid == uuid.uuidString }) {
        
        print(uuid.uuidString)
        
        if(uuid.uuidString == BLEDevice_UUID) {
            print("this should be found")
            debugPrint(allDeviceList)
        }
        
        if(allDeviceList.contains { $0.device_uuid == uuid.uuidString }) {
            print("found kindred device")
            peripherals.append(peripheral)
            peripheral.delegate = self
            self.centralManager?.connect(peripheral, options: nil)
        }
    }
    
    // Connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        debugPrint("Getting services1 ...")
        
        // Ask for services
        peripheral.discoverServices(nil)
        
        // Debug
        debugPrint("Getting services2 ...")
    }
    
    
    // Discovered peripheral services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discovered services")
        
        
        for service in peripheral.services! {
            let thisService = service as CBService
            print("service: " + service.uuid.uuidString);
            
            if service.uuid.uuidString == BLEService_UUID {
                print("subscribing to characteristics")
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    // Discovered peripheral characteristics
    func peripheral( _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discovered service characteristics")
        
        // Look at provided characteristics
        for characteristic in service.characteristics! {
            
            let thisCharacteristic = characteristic as CBCharacteristic
            // set up notifications if this is the right characteristic
            
            if thisCharacteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" { // TODO figure out why these are hard coded???
                readCharacteristic = characteristic // dont know if this is necsesary
                peripheral.setNotifyValue(true, for: thisCharacteristic)
                debugPrint("Set to notify: ", thisCharacteristic.uuid)
            }
            
            if thisCharacteristic.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" {
                writeCharacteristic = characteristic
            }
            
            // Debug
            debugPrint("Characteristic: ", thisCharacteristic.uuid.uuidString)
        }
    }
    
    // Data arrived from peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("data arrived");
        
        // Make sure it is the peripheral we want
        print(self.BLERead_UUID)
        if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" {
            
            // get device info from list
            let device:Device = allDeviceList.filter{ $0.device_uuid == peripheral.identifier.uuidString }.first!
            let studentName:String = device.student_name
            let msg:String = device.device_msg
            
            // send alert
            let alertVC = UIAlertController(title: studentName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
            
            // write message back
            let action = UIAlertAction(title: "acknowledge", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                self.topViewController()?.dismiss(animated: true, completion: nil)
                self.acknowledgeNotification(peripheral: peripheral)
            })
            
            alertVC.addAction(action)
            self.topViewController()?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func topViewController() -> UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        while topViewController.presentedViewController != nil {
            topViewController = topViewController.presentedViewController!
        }
        return topViewController
    }
    
    func acknowledgeNotification(peripheral: CBPeripheral) {
        print("notification acknowledged");
        let response:Data = "done".data(using: .utf8)!
        peripheral.writeValue(response, for: writeCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func getAllDevices() {
        let urlString = "https://kindred-web.herokuapp.com/devices"
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
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    self.allDeviceList = deviceData
                    if(self.scanEnabled) {
                        self.startScan();
                    }
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}


