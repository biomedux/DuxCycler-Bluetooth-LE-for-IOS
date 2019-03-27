//
//  FileName: ActionEditorViewController.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class ActionEditorViewController: UIViewController, EditorTableDelegate {
    
    @IBOutlet var tableActionEditor: ActionEditorTable!
    
    let protocolManager = ProtocolManager.instance
    
    var selectedProtocol: Protocol!
    var selectedIndex: Int!
    
    var saved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableActionEditor.callback = self
        
        if selectedIndex == -1 {
            newProtocol()
        } else {
            setProtocol()
        }
    }
    
    @IBAction func onAddAction(_ sender: Any) {
        let actionEditorDialog = storyboard?.instantiateViewController(withIdentifier: "ActionEditorDialog") as! ActionEditorDialog
        
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .alert)
        alert.setValue(actionEditorDialog, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            action in
            if let action = self.onCheckAction(dialog: actionEditorDialog, index: self.selectedProtocol.actions.count) {
                self.onAddAction(action: action)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
        
        actionEditorDialog.txtLabel.text = String(selectedProtocol.getLastLabel(endIndex: selectedProtocol.actions.count) + 1)
    }
    
    func tableSelectRowAt(index: Int) {
        let actionEditorDialog = storyboard?.instantiateViewController(withIdentifier: "ActionEditorDialog") as! ActionEditorDialog
        
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .alert)
        alert.setValue(actionEditorDialog, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Apply", style: .default, handler: {
            action in
            if let action = self.onCheckAction(dialog: actionEditorDialog, index: index) {
                self.onEditAction(action: action, index: index)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in self.showDeleteDialog(index: index) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
        
        actionEditorDialog.txtLabel.text = selectedProtocol.actions[index].isGoto() ? "GOTO" : String(selectedProtocol.actions[index].label)
        actionEditorDialog.txtTemp.text = String(selectedProtocol.actions[index].temp)
        actionEditorDialog.txtTime.text = String(selectedProtocol.actions[index].time)
        actionEditorDialog.switchGoto.isOn = selectedProtocol.actions[index].isGoto()
    }
    
    @objc func editTitle() {
        let alert = UIAlertController(title: "Protocol", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "Title"
            textField.text = self.selectedProtocol.title
        })
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            if let title = alert.textFields?.first?.text {
                if title == "" {
                    self.showToastMessage(message: "Title is empty.")
                    return
                }
                
                for i in 0 ..< self.protocolManager.protocols.count {
                    if title == self.protocolManager.protocols[i].title && self.selectedIndex != i {
                        self.showToastMessage(message: "Duplicate title.")
                        return
                    }
                }
                
                self.selectedProtocol.title = title
                self.reloadNavigationTitle()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func newProtocol() {
        let alert = UIAlertController(title: "Protocol", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in textField.placeholder = "Title" })
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            if let title = alert.textFields?.first?.text {
                if title == "" {
                    self.newProtocol()
                    return
                }
                
                for i in 0 ..< self.protocolManager.protocols.count {
                    if title == self.protocolManager.protocols[i].title {
                        self.newProtocol()
                        return
                    }
                }
                
                self.selectedProtocol = Protocol()
                self.selectedProtocol.title = title
                self.reloadNavigationTitle()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true)
    }
    
    func setProtocol() {
        selectedProtocol = protocolManager.protocols[selectedIndex].copy()
        
        reloadNavigationTitle()
        reloadActionEditorTable()
    }
    
    func onCheckAction(dialog: ActionEditorDialog, index: Int) -> Action? {
        let sTemp = dialog.txtTemp.text!
        let sTime = dialog.txtTime.text!
        let goto = dialog.switchGoto.isOn
        
        if sTemp == "" {
            self.view.makeToast("Temp is empty.")
            return nil
        }
        
        if sTime == "" {
            self.view.makeToast("Time is empty.")
            return nil
        }
        
        let label = goto ? TxProtocol.AF_GOTO : selectedProtocol.getLastLabel(endIndex: index) + 1
        let temp = Int(sTemp)!
        let time = Int(sTime)!
        
        if label <= 0 || (label >= 250 && !goto) {
            self.view.makeToast("Label is out of range.")
            return nil
        }
        
        if temp <= 0 || (temp >= 105 && !goto) {
            self.view.makeToast("Temp is out of range.")
            return nil
        }
        
        if (time <= 0 && !(time == 0 && temp < 10)) || time >= 65536 {
            self.view.makeToast("Time is out of range.")
            return nil
        }
        
        if goto {
            if temp > selectedProtocol.getLastLabel(endIndex: index) {
                self.view.makeToast("Goto is out of range.")
                return nil
            }
            
            for i in selectedProtocol.indexOf(label: temp) ..< selectedProtocol.actions.count {
                if selectedProtocol.actions[i].isGoto() {
                    if i < index {
                        self.view.makeToast("Goto is duplicated.")
                        return nil
                    } else if i > index {
                        if selectedProtocol.indexOf(label: selectedProtocol.actions[i].temp) > index {
                            break
                        } else {
                            self.view.makeToast("Goto is duplicated.")
                            return nil
                        }
                    }
                }
            }
        }
        
        return Action(label: goto ? TxProtocol.AF_GOTO : label, temp: temp, time: time)
    }
    
    func onAddAction(action: Action) {
        selectedProtocol.actions.append(action)
        reloadActionEditorTable()
    }
    
    func onEditAction(action: Action, index: Int) {
        if selectedProtocol.actions[index].isGoto() != action.isGoto() {
            for i in index + 1 ..< selectedProtocol.actions.count {
                if selectedProtocol.actions[i].isGoto() {
                    selectedProtocol.actions[i].temp += action.isGoto() ? -1 : 1
                } else {
                    selectedProtocol.actions[i].label +=  action.isGoto() ? -1 : 1
                }
            }
        }
        
        selectedProtocol.actions[index] = action
        reloadActionEditorTable()
    }
    
    func showDeleteDialog(index: Int) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this action?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in self.onDeleteAction(index: index)} ))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func onDeleteAction(index: Int) {
        if !selectedProtocol.actions[index].isGoto() {
            for i in index + 1 ..< selectedProtocol.actions.count {
                if selectedProtocol.actions[i].isGoto() {
                    if selectedProtocol.indexOf(label: selectedProtocol.actions[i].temp) > index {
                        selectedProtocol.actions[i].temp = selectedProtocol.actions[i].temp - 1
                    }
                } else {
                    selectedProtocol.actions[i].label = selectedProtocol.actions[i].label - 1
                }
            }
            
            if selectedProtocol.actions.count > index + 1 {
                if selectedProtocol.actions[index + 1].isGoto() {
                    if selectedProtocol.indexOf(label: selectedProtocol.actions[index + 1].temp) == index {
                        selectedProtocol.actions.remove(at: index + 1)
                    }
                }
            }
        }
        
        selectedProtocol.actions.remove(at: index)
        reloadActionEditorTable()
    }
    
    func isChanged() -> Bool {
        if selectedProtocol == nil {
            return false
        }
        
        if selectedIndex == -1 {
            return selectedProtocol.actions.count > 0
        }
        
        return protocolManager.protocols[selectedIndex] != selectedProtocol
    }
    
    func save() {
        let alert = UIAlertController(title: "Save", message: "Are you sure you want to save this protocol?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            if self.selectedIndex == -1 {
                self.protocolManager.protocols.append(self.selectedProtocol)
            } else {
                self.protocolManager.protocols[self.selectedIndex] = self.selectedProtocol
            }
            
            self.protocolManager.save()
            
            self.navigationController?.popViewController(animated: true)
            self.saved = true
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: {
            action in
            
            self.navigationController?.popViewController(animated: true)
            self.saved = true
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func reloadNavigationTitle() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle(selectedProtocol.title, for: .normal)
        button.setTitleColor(.darkText, for: .normal)
        button.addTarget(self, action: #selector(self.editTitle), for: .touchUpInside)
        
        self.navigationItem.titleView = button
    }
    
    func reloadActionEditorTable() {
        tableActionEditor.selectedProtocol = selectedProtocol
        tableActionEditor.reloadData()
    }
    
    func showToastMessage(message: String) {
        self.view.hideAllToasts()
        self.view.makeToast(message)
    }
}
