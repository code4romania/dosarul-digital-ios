//
//  NavigationDrawer.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/05/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

enum NavigationDrawerItemPosition {
    case top, bottom
}

protocol NavigationDrawerDataSource {
    func headerImage(for navigationDrawer:NavigationDrawer) -> UIImage?
    func width(for navigationDrawer:NavigationDrawer) -> CGFloat
    func numberOfViewControllers(in navigationDrawer:NavigationDrawer) -> Int
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, titleForButtonAt index: Int) -> String?
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, imageForButtonAt index: Int) -> UIImage?
    func navigationDrawer(_ navigationDrawer:NavigationDrawer, positionForButtonAt index: Int) -> NavigationDrawerItemPosition
}

extension NavigationDrawerDataSource {
    func headerImage(for navigationDrawer:NavigationDrawer) -> UIImage? { return nil }
    func width(for navigationDrawer:NavigationDrawer) -> CGFloat { return 288 }
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, titleForButtonAt index: Int) -> String? { return nil }
    func navigationDrawer(_ navigationDrawer: NavigationDrawer, imageForButtonAt index: Int) -> UIImage? { return nil }
    func navigationDrawer(_ navigationDrawer:NavigationDrawer, positionForButtonAt index: Int) -> NavigationDrawerItemPosition {
        return .top
    }
    
}

@objc protocol NavigationDrawerDelegate {
    @objc func navigationDrawer(_ navigationDrawer:NavigationDrawer, didTapButtonAt index:Int)
}

class NavigationDrawer: UIViewController {

    var selectedIndex: Int?
    
    var delegate: NavigationDrawerDelegate?
    var dataSource: NavigationDrawerDataSource?

    private var containerView = UIView()
    private var imageView = UIImageView()
    private var topView = UIView()
    
    private var buttons = [DrawerButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDynamicLayout()
    }

    func configureLayout() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.navigationDrawerBackground
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if let width = dataSource?.width(for: self) {
            containerView.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        containerView.addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 190).isActive = true
        topView.backgroundColor = UIColor.navigationDrawerForeground

        topView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -43).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 212).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        imageView.image = self.dataSource?.headerImage(for: self)
        
        if let numberOfButtons = self.dataSource?.numberOfViewControllers(in: self) {
            var topPinningView: UIView?
            var bottomPinningView: UIView?
            for index in 0..<numberOfButtons {
                let button = DrawerButton()
                button.setTitle(dataSource?.navigationDrawer(self, titleForButtonAt: index), for: .normal)
                button.setImage(dataSource?.navigationDrawer(self, imageForButtonAt: index), for: .normal)
                button.addTarget(self, action: #selector(buttonTouched(sender:)), for: .touchUpInside) 
                buttons.append(button)
                
                containerView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
                button.heightAnchor.constraint(equalToConstant: 52).isActive = true
                button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
                let position = dataSource?.navigationDrawer(self, positionForButtonAt: index) ?? NavigationDrawerItemPosition.top
                switch position {
                case .top:
                    if let topPinningView = topPinningView {
                        button.topAnchor.constraint(equalTo: topPinningView.bottomAnchor, constant: 2).isActive = true
                    } else {
                        button.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 24).isActive = true
                    }
                    topPinningView = button
                case.bottom:
                    if let bottomPinningView = bottomPinningView {
                        button.topAnchor.constraint(equalTo: bottomPinningView.bottomAnchor, constant: 2).isActive = true
                    }
                    bottomPinningView = button
                }
            }
            bottomPinningView?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
        }
    }
    
    func configureDynamicLayout() {
        for button in buttons {
            button.isHighlighted = false
        }
        buttons[selectedIndex ?? 0].isHighlighted = true
    }

    @objc func buttonTouched(sender: DrawerButton) {
        if let buttonIndex = buttons.firstIndex(of: sender) {
            selectedIndex = buttonIndex
            delegate?.navigationDrawer(self, didTapButtonAt: buttonIndex)
        }
    }
    
}
