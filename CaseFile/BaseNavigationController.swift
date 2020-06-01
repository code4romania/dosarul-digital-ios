//
//  BaseNavigationController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit
import SideMenu

class BaseViewController: UIViewController {

    private var selectedIndex: Int = 0 {
        didSet {
            
        }
    }
    private let drawerWidth: CGFloat = 288
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(image: UIImage(named: "button-menu"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(navigationMenuButtonTouched(sender:)))
        navigationController?.topViewController?.navigationItem.rightBarButtonItem = rightButton
    }
    
    /// Navigation drawer
    @objc private func navigationMenuButtonTouched(sender: UIButton) {
        AppRouter.shared.showNavigationDrawer()
    }
    

}
