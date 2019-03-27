//
//  FileName: PCRViewController.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class PCRViewController: UIViewController, UITabBarControllerDelegate, UITextFieldDelegate, BluetoothLEDeviceDialogDelegate, BluetoothLEServiceDelegate {
    
    static let MODE_READY = 0
    static let MODE_OBSERVER = 1
    static let MODE_TASK_READ = 2
    static let MODE_TASK_WRITE = 3
    static let MODE_TASK_END = 4
    static let MODE_GO = 5
    static let MODE_STOP = 6
    
    @IBOutlet var txtTotalTime: UILabel!
    @IBOutlet var imgGreenLED: UIImageView!
    @IBOutlet var imgBlueLED: UIImageView!
    @IBOutlet var imgRedLED: UIImageView!
    
    @IBOutlet var txtChamber: UILabel!
    @IBOutlet var txtLidHeater: UILabel!
    @IBOutlet var btnPreheat: UIButton!
    
    @IBOutlet var tableAction: ActionTable!
    
    let bleService = BluetoothLEService()
    var bleDeviceDialog: BluetoothLEDeviceDialog!
    var bleDeviceAlert: UIAlertController!
    
    let protocolManager = ProtocolManager.instance
    var selectedProtocol: Protocol!
    
    var updateTimer: Timer?
    
    var progressLock = false
    var buttonLock = false
    
    var lineToggleCount = 0
    var ledToggleCount = 0
    var taskLineCount = 0
    var pcrStart = false
    var pcrEnd = false
    var runRefrigerator = false
    
    var mode = MODE_READY
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleService.delegate = self
        
        bleDeviceDialog = storyboard?.instantiateViewController(withIdentifier: "BluetoothLEDeviceDialog") as? BluetoothLEDeviceDialog
        bleDeviceDialog.callback = self
        
        bleDeviceAlert = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        bleDeviceAlert.setValue(bleDeviceDialog, forKey: "contentViewController")
        bleDeviceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            self.bleService.scanStop()
        }))
        
        protocolManager.load()
        selectedProtocol = protocolManager.getSelectedProtocol()
        
        if selectedProtocol != nil {
            onUpdateTime(time: ActionUtil.calcTime(selectedProtocol: selectedProtocol))
        }
        
        reloadActionTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tabbar = tabBarController as! AppTabBar
        tabbar.delegates.append(self)
    }
    
    func initialization() {
        navigationItem.title = "PCR"
        navigationItem.rightBarButtonItem = nil
        updateTimer?.invalidate()
        updateTimer = nil
        
        lineToggleCount = 0
        ledToggleCount = 0
        taskLineCount = 0
        pcrStart = false
        pcrEnd = false
        runRefrigerator = false
        
        mode = PCRViewController.MODE_READY
        
        onUpdateTime(time: ActionUtil.calcTime(selectedProtocol: selectedProtocol))
        onUpdateLED(red: false, green: false, blue: false)
        
        txtChamber.text = "0.0°C"
        txtLidHeater.text = "0.0°C"
        
        selectedProtocol.clearRemain()
        tableAction.toggleRowAt(row: -1)
        reloadActionTable()
    }
    
    @IBAction func onPreheat(_ sender: Any) {
        if pcrStart || buttonLock {
            return
        }
        
        let alert = UIAlertController(title: "Preheat", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "Preheat"
            textField.text = self.btnPreheat.titleLabel?.text
            textField.keyboardType = UIKeyboardType.numberPad
            textField.delegate = self
        })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            if let preheat = alert.textFields?.first?.text {
                if preheat == "" {
                    self.showToastMessage(message: "Preheat is empty.")
                    return
                }
                
                if let value = Int(preheat) {
                    if value <= 0 || value > 104 {
                        self.view.makeToast("Preheat is out of range.")
                        return
                    }
                }
                
                self.btnPreheat.setTitle(preheat, for: .normal)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        if buttonLock {
            return
        }
        
        bleDeviceDialog.devices.removeAll()
        bleDeviceDialog.tableBluetoothLEDevice.reloadData()
        
        bleService.scanStart()
        
        present(bleDeviceAlert, animated: true)
    }
    
    @IBAction func onStart(_ sender: Any) {
        if buttonLock {
            return
        }
        
        showProgressSpinner()
        mode = PCRViewController.MODE_READY
    }
    
    @IBAction func onStop(_ sender: Any) {
        if buttonLock {
            return
        }
        
        let alert = UIAlertController(title: "Stop", message: "Do you want to stop PCR?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.showProgressSpinner()
            self.mode = PCRViewController.MODE_STOP
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        selectedProtocol = protocolManager.getSelectedProtocol()
        reloadActionTable()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return !(pcrStart || buttonLock)
    }
    
    func bluetoothLEDeviceSelected(device: BluetoothLEDevice) {
        showProgressSpinner()
        
        if bleService.isConnected() {
            progressLock = true
            bleService.close()
        }
        
        bleDeviceAlert.dismiss(animated: true, completion: nil)
        bleService.scanStop()
        bleService.connect(device: device)
        
        navigationItem.title = bleDeviceDialog.findNameOf(device: device)
    }
    
    func bluetoothLEScan(device: BluetoothLEDevice) {
        for dvc in bleDeviceDialog.devices {
            if dvc.uuid == device.uuid {
                return
            }
        }
        
        bleDeviceDialog.devices.append(device)
        bleDeviceDialog.tableBluetoothLEDevice.reloadData()
    }
    
    func bluetoothLEUpdateState(state: Int) {
        if state == 0 {
            showErrorDialog(title: "Sorry!", message: "BluetoothLE is unknown.")
            
        } else if state == 1 {
            showErrorDialog(title: "Sorry!", message: "BluetoothLE is resetting.")
            
        } else if state == 2 {
            showErrorDialog(title: "Sorry!", message: "BluetoothLE is unsupported.")
            
        } else if state == 3 {
            showErrorDialog(title: "Sorry!", message: "BluetoothLE is unauthorized.")
            
        } else if state == 4 {
            initialization();
            hideProgressSpinner()
            progressLock = false
            
            showDialog(title: "Warning", message: "BluetoothLE is powered off.")
            
        } else if state == 5 {
             // Powered on
            
        }
    }
    
    func bluetoothLEEvent(msg: Int) {
        if msg == 0 { // Connected
            showProgressSpinner()
            showToastMessage(message: "Connected.")
            
        } else if msg == 1 { // Disconnected
            initialization();
            
            if !progressLock {
                hideProgressSpinner()
            }
            progressLock = false
            
            showToastMessage(message: "Disconnected.")
            
        } else if msg == 2 { // Discovered
            updateTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        }
    }
    
    func bluetoothLEReceived(rxData: RxData) {
        if mode == PCRViewController.MODE_READY {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onStop(_:)))
            lineToggleCount = 0
            ledToggleCount = 0
            taskLineCount = 0
            pcrStart = true
            pcrEnd = false
            runRefrigerator = false
            
            if rxData.state == State.RUN.rawValue {
                selectedProtocol = Protocol()
                onUpdateTime(time: 0)
                reloadActionTable()
                
                mode = PCRViewController.MODE_TASK_READ
            } else {
                mode = PCRViewController.MODE_TASK_WRITE
            }
            
        } else if mode == PCRViewController.MODE_OBSERVER {
            onUpdate(rxData: rxData)
            
            
            if rxData.currentOperation == StateOperation.RUN_REFRIGERATOR.rawValue {
                if !runRefrigerator {
                    runRefrigerator = true
                    showToastMessage(message: "Run Refrigerator")
                }
                
            } else if rxData.currentOperation != StateOperation.INIT.rawValue {
                if !pcrEnd {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(onStart(_:)))
                    pcrStart = false
                    pcrEnd = true
                    runRefrigerator = false
                    
                    selectedProtocol.clearRemain()
                    tableAction.toggleRowAt(row: -1)
                    reloadActionTable()
                    
                    hideProgressSpinner()
                    
                    if rxData.currentOperation == StateOperation.COMPLETE.rawValue {
                        showToastMessage(message: "PCR Complete")
                        
                    } else if rxData.currentOperation == StateOperation.INCOMPLETE.rawValue {
                        showToastMessage(message: "PCR Incomplete")
                        
                    }
                }
            }
            
        } else if mode == PCRViewController.MODE_TASK_READ {
            if taskLineCount == rxData.requestLine {
                selectedProtocol.actions.append(rxData.getRequestAction())
                reloadActionTable()
                
                if taskLineCount == rxData.labelCount - 1 {
                    hideProgressSpinner()
                    mode = PCRViewController.MODE_OBSERVER
                } else {
                    taskLineCount += 1
                }
            }
            
        } else if mode == PCRViewController.MODE_TASK_WRITE {
            if rxData.state == State.TASK_WRITE.rawValue {
                if rxData.getRequestAction() == selectedProtocol.actions[taskLineCount] &&  rxData.requestLine == taskLineCount {
                    if taskLineCount == selectedProtocol.actions.count - 1 {
                        mode = PCRViewController.MODE_TASK_END
                    } else {
                        taskLineCount += 1
                    }
                }
            }
            
        } else if mode == PCRViewController.MODE_TASK_END {
            if rxData.state == State.READY.rawValue {
                mode = PCRViewController.MODE_GO
            }
            
        } else if mode == PCRViewController.MODE_GO {
            if rxData.state == State.RUN.rawValue {
                hideProgressSpinner()
                mode = PCRViewController.MODE_OBSERVER
            }
            
        } else if mode == PCRViewController.MODE_STOP {
            if rxData.state == State.STOP.rawValue || rxData.state == State.READY.rawValue {
                mode = PCRViewController.MODE_OBSERVER
            }
        }
    }
    
    @objc func onTimer() {
        if mode == PCRViewController.MODE_READY || mode == PCRViewController.MODE_OBSERVER {
            bleService.write(data: TxProtocolHelper.makeNop())
            
        } else if mode == PCRViewController.MODE_TASK_WRITE {
            bleService.write(data: TxProtocolHelper.makeTaskWrite(action: selectedProtocol.actions[taskLineCount], preheat: Int(btnPreheat.titleLabel!.text!)!, line: taskLineCount))
            
        } else if mode == PCRViewController.MODE_TASK_READ {
            bleService.write(data: TxProtocolHelper.makeRequestLine(line: taskLineCount))
            
        } else if mode == PCRViewController.MODE_TASK_END {
            bleService.write(data: TxProtocolHelper.makeTaskEnd())
        
        } else if mode == PCRViewController.MODE_GO {
            bleService.write(data: TxProtocolHelper.makeGo())
            
        } else if mode == PCRViewController.MODE_STOP {
            bleService.write(data: TxProtocolHelper.makeStop())
            
        }
    }
    
    func onUpdate(rxData: RxData) {
        onUpdateState(rxData: rxData)
        
        onUpdateTemp(rxData: rxData)
        
        onUpdateTime(time: rxData.totalTime)
        
        onUpdateLine(rxData: rxData)
    }
    
    func onUpdateLine(rxData: RxData) {
        var index: Int!
        
        if rxData.state == State.RUN.rawValue {
            index = selectedProtocol.indexOf(label: rxData.currentLabel)
            
            if (rxData.currentLabel > 0) {
                
                selectedProtocol.clearRemain()
                selectedProtocol.actions[index].remain = rxData.lineTime
                
                for i in index ..< selectedProtocol.actions.count {
                    if selectedProtocol.actions[i].isGoto() {
                        if rxData.gotoCount == 255 {
                            if selectedProtocol.actions[i].temp <= rxData.currentLabel {
                                selectedProtocol.actions[i].remain = selectedProtocol.actions[i].time
                            }
                        } else {
                            selectedProtocol.actions[i].remain = rxData.gotoCount
                        }
                        
                        break
                    }
                }
                
                reloadActionTable()
                
                lineToggleCount += 1
                if lineToggleCount == 4 {
                    tableAction.toggleRowAt(row: index)
                    lineToggleCount = 0
                }
            }
        }
    }
    
    func onUpdateState(rxData: RxData) {
        if rxData.state == State.READY.rawValue {
            if rxData.currentOperation == StateOperation.INIT.rawValue {
                onUpdateLED(red: false, green: true, blue: false)
            } else if rxData.currentOperation == StateOperation.COMPLETE.rawValue {
                onUpdateLED(red: false, green: true, blue: true)
            } else if rxData.currentOperation == StateOperation.INCOMPLETE.rawValue {
                onUpdateLED(red: true, green: true, blue: false)
            }
        } else if rxData.state == State.RUN.rawValue {
            if rxData.currentOperation == StateOperation.RUN_REFRIGERATOR.rawValue {
                onUpdateLED(red: false, green: true, blue: true)
            } else {
                if ledToggleCount < 3 {
                    onUpdateLED(red: false, green: true, blue: false)
                } else {
                    onUpdateLED(red: false, green: true, blue: true)
                }
                
                ledToggleCount += 1
                if ledToggleCount == 6 {
                    ledToggleCount = 0
                }
            }
        } else if rxData.state == State.PCR_END.rawValue {
            onUpdateLED(red: false, green: true, blue: true)
        }
    }
    
    func onUpdateTemp(rxData: RxData) {
        txtChamber.text = String(format: "%4.1f°C", rxData.chamberTemp)
        txtLidHeater.text = String(format: "%4.1f°C", rxData.lidTemp)
    }
    
    func onUpdateTime(time: Int) {
        txtTotalTime.text = String(format: "%02d:%02d:%02d", time / 3600, time / 60 % 60, time % 60)
    }
    
    func onUpdateLED(red: Bool, green: Bool, blue: Bool) {
        imgRedLED.image = red ? UIImage(named: "led_red") : UIImage(named: "led_gray")
        imgGreenLED.image = green ? UIImage(named: "led_green") : UIImage(named: "led_gray")
        imgBlueLED.image = blue ? UIImage(named: "led_blue") : UIImage(named: "led_gray")
    }
    
    func reloadActionTable() {
        tableAction.selectedProtocol = selectedProtocol
        tableAction.reloadData()
    }
    
    func showDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func showErrorDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {
            action in
            exit(0)
        }))
        
        present(alert, animated: true)
    }
    
    func showToastMessage(message: String) {
        self.view.hideAllToasts()
        self.view.makeToast(message)
    }
    
    func showProgressSpinner() {
        self.view.makeToastActivity(.center)
        buttonLock = true
    }
    
    func hideProgressSpinner() {
        self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        buttonLock = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newLength = text.count + string.count - range.length
            
            return newLength <= 3 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        }
        
        return false
    }
}
