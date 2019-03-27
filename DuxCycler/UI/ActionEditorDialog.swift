//
//  FileName: ActionEditorDialog.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class ActionEditorDialog: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtLabel: UITextField!
    @IBOutlet var txtTemp: UITextField!
    @IBOutlet var txtTime: UITextField!
    @IBOutlet var switchGoto: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtLabel.delegate = self
        txtTemp.delegate = self
        txtTime.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newLength = text.count + string.count - range.length
            
            return newLength <= 5 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        }
        
        return false
    }
}
