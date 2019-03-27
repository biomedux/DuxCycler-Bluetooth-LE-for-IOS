//
//  FileName: ProtocolEditorTable.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class ProtocolEditorTable: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var callback: EditorTableDelegate?
    
    var protocols:[Protocol]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
        dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let protos = protocols {
            return protos.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "ProtocolEditorCell", for: indexPath) as! ProtocolEditorCell
        let proto = protocols![indexPath.row]
        
        cell.txtTitle.text = proto.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback?.tableSelectRowAt(index: indexPath.row)
    }
}
