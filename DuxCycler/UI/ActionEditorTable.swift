//
//  FileName: ActionEditorTable.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class ActionEditorTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var callback: EditorTableDelegate?
    
    var selectedProtocol:Protocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
        dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let proto = selectedProtocol {
            return proto.actions.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "ActionEditorCell", for: indexPath) as! ActionEditorCell
        let action = selectedProtocol!.actions[indexPath.row]
        
        cell.txtLabel.text = action.isGoto() ? "GOTO" : String(action.label)
        cell.txtTemp.text = String(action.temp)
        cell.txtTime.text = action.isGoto() ? String(action.time) : (action.time == 0 ? "∞" : ActionUtil.toHMS(time: action.time))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback?.tableSelectRowAt(index: indexPath.row)
    }
}
