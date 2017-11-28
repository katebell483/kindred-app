import CoreBluetooth
import UIKit

public class BluetoothService: NSObject {
    
    var manager: CBCentralManager!
    var characteristic: CBCharacteristic!
    
    var peripheral: CBPeripheral!
    
    //var writeCharacteristic: CBCharacteristic?
    //var readCharacteristic: CBCharacteristic?
    var scanEnabled:Bool = false

    // devices
    var deviceList = [Device]()
    
    // peripheral list
    var writeCharacteristics: [CBPeripheral: CBCharacteristic] = [:]
    var peripherals: [CBPeripheral] = []
    var BLEService_UUID:String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    let service_uuid: CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

    var BLEDevice_UUID:String = "379B5933-F6FC-00BB-AFF4-CF8E1269327B"
    var BLERead_UUID:String = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    var BLEWrite_UUID:String = "6E400002-B5A3-F393-­E0A9-­E50E24DCCA9E"
    
    static let shared = BluetoothService()
    private override init() {
        super.init()
        self.updateDevices()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func updateDevices() {
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
                    self.deviceList = deviceData
                    if(self.scanEnabled) {
                        self.manager?.scanForPeripherals(withServices: [self.service_uuid], options: nil)
                    }
                }
                
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
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
        let writeCharacteristic:CBCharacteristic = writeCharacteristics[peripheral]!
        peripheral.writeValue(response, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState: \(central.state.rawValue)")
        if (central.state == CBManagerState.poweredOn) {
            print("BLE Enabled")
            self.scanEnabled = true
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("didDiscover peripheral")
        
        let uuid:UUID = peripheral.identifier;
        
        if(uuid.uuidString == BLEDevice_UUID) {
            print("this should be found")
            debugPrint(deviceList)
        }
        
        if(deviceList.contains { $0.device_uuid == uuid.uuidString }) {
            print("found kindred device")
            peripherals.append(peripheral)
            peripheral.delegate = self
            self.manager.connect(peripheral, options: nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect")
        peripheral.discoverServices([service_uuid])
    }
    
}

extension BluetoothService: CBPeripheralDelegate {
    // Discovered peripheral services
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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
    public func peripheral( _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discovered service characteristics")
        
        // Look at provided characteristics
        for characteristic in service.characteristics! {
            
            let thisCharacteristic = characteristic as CBCharacteristic
            // set up notifications if this is the right characteristic
            
            if thisCharacteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" { // TODO figure out why these are hard coded???
                //readCharacteristic = characteristic // dont know if this is necsesary
                peripheral.setNotifyValue(true, for: thisCharacteristic)
                debugPrint("Set to notify: ", thisCharacteristic.uuid)
            }
            
            if thisCharacteristic.uuid.uuidString == "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" {
                writeCharacteristics[peripheral] = characteristic
                //writeCharacteristic = characteristic
            }
            
            // Debug
            debugPrint("Characteristic: ", thisCharacteristic.uuid.uuidString)
        }
    }
    
    // Data arrived from peripheral
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("data arrived");
        
        // Make sure it is the peripheral we want
        print(self.BLERead_UUID)
        if characteristic.uuid.uuidString == "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" {
            
            // get device info from list
            let device:Device = deviceList.filter{ $0.device_uuid == peripheral.identifier.uuidString }.first!
            let studentName:String = device.student_name
            let msg:String = device.device_msg
            
            // send alert
            let alertVC = UIAlertController(title: studentName, message: msg, preferredStyle: UIAlertControllerStyle.alert)
            
            // write message back
            let action = UIAlertAction(title: "acknowledge", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) -> Void in
                //self.topViewController()?.dismiss(animated: true, completion: nil)
                self.acknowledgeNotification(peripheral: peripheral)
            })
            
            alertVC.addAction(action)
            self.topViewController()?.present(alertVC, animated: true, completion: nil)
        }
    }
    
}
