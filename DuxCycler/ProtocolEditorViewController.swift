//
//  FileName: ProtocolEditorViewController.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class ProtocolEditorViewController: UIViewController, UITabBarControllerDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate, EditorTableDelegate {
    
    @IBOutlet var tableProtocolEditor: ProtocolEditorTable!
    
    let protocolManager = ProtocolManager.instance
    
    var appTabBar: AppTabBar!
    
    var actionEditorViewController: ActionEditorViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        tableProtocolEditor.callback = self
        
        reloadProtocolEditorTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        appTabBar = tabBarController as? AppTabBar
        appTabBar.delegates.append(self)
    }
    
    @IBAction func onAddProtocol(_ sender: Any) {
        showActionEditorViewController(selectedIndex: -1)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if actionEditorViewController != nil {
            if navigationController?.topViewController == actionEditorViewController {
                reloadProtocolEditorTable()
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if actionEditorViewController != nil {
            if navigationController?.topViewController == actionEditorViewController {
                if !actionEditorViewController.saved {
                    if actionEditorViewController.isChanged() {
                        actionEditorViewController.save()
                        return false
                    }
                }
                
                self.navigationController?.popViewController(animated: true)
                return false
            }
        }
        
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        reloadProtocolEditorTable()
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if !actionEditorViewController.saved {
            if actionEditorViewController.isChanged() {
                actionEditorViewController.save()
                return false;
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        return true
    }
    
    func tableSelectRowAt(index: Int) {
        let alert = UIAlertController(title: protocolManager.protocols[index].title, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { action in self.onSelect(index: index)} ))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in self.onEdit(index: index)}))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in self.showDeleteDialog(index: index)}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func onSelect(index: Int) {
        protocolManager.selectedIndex = index
        protocolManager.save()
        
        appTabBar.setSelectedIndex(index: 0)
    }
    
    func onEdit(index: Int) {
        showActionEditorViewController(selectedIndex: index)
    }
    
    func onDelete(index: Int) {
        if protocolManager.selectedIndex == index {
            protocolManager.selectedIndex = -1
        }
        
        protocolManager.protocols.remove(at: index)
        protocolManager.save()
        
        reloadProtocolEditorTable()
    }
    
    func showActionEditorViewController(selectedIndex: Int) {
        actionEditorViewController = storyboard?.instantiateViewController(withIdentifier: "ActionEditorViewController") as? ActionEditorViewController
        actionEditorViewController.selectedIndex = selectedIndex
        navigationController?.pushViewController(actionEditorViewController, animated: true)
    }
    
    func showDeleteDialog(index: Int) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this protocol?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in self.onDelete(index: index)} ))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    func reloadProtocolEditorTable() {
        tableProtocolEditor.protocols = protocolManager.protocols
        tableProtocolEditor.reloadData()
    }
}
