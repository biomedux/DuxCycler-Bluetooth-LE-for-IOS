//
//  FileName: ActionTable.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class ActionTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var selectedProtocol:Protocol?
    
    var toggle = false
    
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
        let cell = dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
        let action = selectedProtocol!.actions[indexPath.row]
        
        cell.txtLabel.text = action.isGoto() ? "GOTO" : String(action.label)
        cell.txtTemp.text = String(action.temp)
        cell.txtTime.text = action.isGoto() ? String(action.time) : (action.time == 0 ? "∞" : ActionUtil.toHMS(time: action.time))
        cell.txtRemain.text = action.remain > 0 ? (action.isGoto() ? String(action.remain) : ActionUtil.toHMS(time: action.remain)) : ""
        
        return cell
    }
    
    func toggleRowAt(row: Int) {
        var selectedCell: ActionCell!
        var cell: ActionCell!
        
        for i in 0 ..< selectedProtocol!.actions.count {
            cell = cellForRow(at: IndexPath(row: i, section: 0)) as? ActionCell
            cell.backgroundColor = UIColor.white
        }
        
        if row >= 0 && row < selectedProtocol!.actions.count {
            if toggle {
                selectedCell = cellForRow(at: IndexPath(row: row, section: 0)) as? ActionCell
                selectedCell.backgroundColor = UIColor.lightGray
            }
            
            toggle = !toggle
        }
    }
}
