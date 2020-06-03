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
    
    lazy var pages: [UIViewController] = {
        model.children.map { OnboardingChildViewController(withModel: $0) }
    }()
    
    @IBOutlet weak var pageControllerContainer: UIView!
    @IBOutlet weak var pager: UIPageControl!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(pageController)
        pageController.view.frame = pageControllerContainer.bounds
        pageControllerContainer.addSubview(pageController.view)
        
        pageController.delegate = self
        pageController.dataSource = self
        
        pageController.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        
        backButton.setTitleColor(UIColor.cn_lightBlue, for: .normal)
        backButton.setTitleColor(UIColor.cn_lightGray, for: .disabled)
        proceedButton.setTitleColor(UIColor.cn_lightBlue, for: .normal)
        proceedButton.setTitleColor(UIColor.cn_lightGray, for: .disabled)
        view.backgroundColor = UIColor.viewBackgroundPrimary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MVAnalytics.shared.log(event: .screen(name: String(describing: type(of: self))))
    }
    
    func updateInterface() {
        pager.currentPage = model.currentPage
        
        UIView.performWithoutAnimation {
            backButton.setTitle("Button_OnboardingPrevious".localized, for: .normal)
            backButton.layoutIfNeeded()
            proceedButton.setTitle(model.currentPage != pages.count - 1 ? "Button_OnboardingNext".localized : "Button_OnboardingStart".localized,
                                   for: .normal)
            proceedButton.layoutIfNeeded()
        }
        
        backButton.isEnabled = model.currentPage != 0
        
        MVAnalytics.shared.log(event: .onboardingPage(page: model.currentPage))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBAction func handlePreviousAction(_ sender: Any) {
        if (model.currentPage != 0) {
            pageController.setViewControllers([pages[model.currentPage - 1]], direction: .reverse, animated: true) { [weak self] completed in
                if let first = self?.pageController.viewControllers?.first,
                    let index = self?.pages.firstIndex(of: first),
                    self?.model.currentPage != index {
                    self?.model.currentPage = index
                }
                self?.updateInterface()
            }
        }
    }
    
    @IBAction func handleProceedAction(_ sender: Any) {
        if (model.currentPage != pages.count - 1) {
            pageController.setViewControllers([pages[model.currentPage + 1]], direction: .forward, animated: true) { [weak self] completed in
                if let first = self?.pageController.viewControllers?.first,
                    let index = self?.pages.firstIndex(of: first),
                    self?.model.currentPage != index {
                    self?.model.currentPage = index
                }
                self?.updateInterface()
            }
        } else {
            PreferencesManager.shared.wasOnboardingShown = true
            AppRouter.shared.goToWelcomeScreen()
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
            index > 0 {
            return pages[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController),
            index < pages.count - 1 {
            return pages[index + 1]
        }
        return nil
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let first = pageViewController.viewControllers?.first,
            let index = pages.firstIndex(of: first),
            model.currentPage != index {
            model.currentPage = index
        }
        updateInterface()
    }
}
