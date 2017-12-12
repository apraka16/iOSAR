//
//  ViewController+TabBarDelegate.swift
//  iOSAR
//
//  Created by Abhinav Prakash on 12/12/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController: UITabBarControllerDelegate {
    
    // If user goes to Settings Tab Bar, reset the whole game
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.tag == 2 {
            self.resetTracking()
        }
    }
    
}
