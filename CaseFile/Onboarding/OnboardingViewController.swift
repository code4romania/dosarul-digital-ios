//
//  OnboardingViewController.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    let model = OnboardingViewModel()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.text = model.topText
        descriptionView.text = model.mainText
        proceedButton.setTitle(model.proceed, for: .normal)
        imageView.image = model.image
        
        let navigationImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 105, height: 18))
        navigationImage.image = model.navigationImage
        navigationImage.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MVAnalytics.shared.log(event: .screen(name: String(describing: type(of: self))))
    }
    
    @IBAction func handleProceedAction(_ sender: Any) {
        PreferencesManager.shared.wasOnboardingShown = true
        AppRouter.shared.goToDashboard()
    }
}
