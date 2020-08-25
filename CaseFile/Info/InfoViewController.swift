//
//  ViewController.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 25/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class InfoViewController: MVViewController {
    
    @IBOutlet weak var logoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Title.Info".localized
        
        logoView.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        logoView.layer.shadowOpacity = 1
        logoView.layer.shadowOffset = .zero
        logoView.layer.shadowRadius = Configuration.shadowRadius

    }

}
