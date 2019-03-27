//
//  FileName: BluetoothLEDeviceDialog.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class BluetoothLEDeviceDialog: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableBluetoothLEDevice: UITableView!
    
    var callback: BluetoothLEDeviceDialogDelegate?
    
    var deviceNames: [BluetoothLEDevice]!
    var devices = [BluetoothLEDevice]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(tableViewLongPress)))
        
        tableBluetoothLEDevice.delegate = self
        tableBluetoothLEDevice.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        deviceNames = StorageUtil.loadDevices()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableBluetoothLEDevice.dequeueReusableCell(withIdentifier: "BluetoothLEDeviceCell", for: indexPath) as! BluetoothLEDeviceCell
        let device = devices[indexPath.row]
        
        if let deviceNmae = self.findDeviceNameOf(device: device) {
            cell.txtName.text = deviceNmae.name
        } else {
            cell.txtName.text = device.name
        }
        
        cell.txtUUID.text = device.uuid
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback?.bluetoothLEDeviceSelected(device: devices[indexPath.row])
    }
    
    @objc func tableViewLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.began {
            if let point = tableBluetoothLEDevice.indexPathForRow(at: recognizer.location(in: view)) {
                let alert = UIAlertController(title: "Device Name", message: nil, preferredStyle: .alert)
                let device = self.devices[point[1]]
                
                alert.addTextField(configurationHandler: {
                    textField in
                    
                    if let deviceNmae = self.findDeviceNameOf(device: device) {
                        textField.text = deviceNmae.name
                    } else {
                        textField.text = device.name
                    }
                    
                    textField.placeholder = "Name"
                })
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                    action in
                    if let name = alert.textFields?.first?.text {
                        if name == "" {
                            self.showToastMessage(message: "Name is empty.")
                            return
                        }
                        
                        if let deviceNmae = self.findDeviceNameOf(device: device) {
                            deviceNmae.name = name
                        } else {
                            self.deviceNames.append(BluetoothLEDevice(name: name, uuid: device.uuid))
                        }
                        
                        self.tableBluetoothLEDevice.reloadData()
                        
                        StorageUtil.saveDevices(devices: self.deviceNames)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true)
            }
        }
    }
    
    func findDeviceNameOf(device: BluetoothLEDevice) -> BluetoothLEDevice? {
        for i in 0 ..< deviceNames.count {
            if deviceNames[i].uuid == device.uuid {
                return deviceNames[i]
            }
        }
        
        return nil
    }
    
    func findNameOf(device: BluetoothLEDevice) -> String {
        if let deviceName = findDeviceNameOf(device: device) {
            return deviceName.name
        }
        
        return device.name
    }
    
    func showToastMessage(message: String) {
        self.view.hideAllToasts()
        self.view.makeToast(message)
    }
}
