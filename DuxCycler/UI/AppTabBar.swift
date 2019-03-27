//
//  FileName: AppTabBar.swift
//  Author  : JaeHong Min
//  Date    : 2019.3.17
//

import UIKit

class AppTabBar: UITabBarController, UITabBarControllerDelegate {
    
    var delegates = [UITabBarControllerDelegate]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        delegates[tabBarController.selectedIndex].tabBarController!(tabBarController, didSelect: viewController)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return delegates[tabBarController.selectedIndex].tabBarController!(tabBarController, shouldSelect: viewController)
    }
    
    func setSelectedIndex(index: Int) {
        selectedIndex = index
        delegates[index].tabBarController!(self, didSelect: viewControllers![index])
    }
}
