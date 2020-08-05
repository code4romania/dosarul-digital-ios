//
//  TitleButtonTableHeader.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 28/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

protocol GenericTableHeaderDelegate: AnyObject {
    func genericTableHeader(_ tableHeader: GenericTableHeader, didTap button: UIButton)
}

class GenericTableHeader: UIView {

    weak var delegate: GenericTableHeaderDelegate?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = UIColor.defaultTableHeaderText
        return label
    }()
    
    var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.cn_lightBlue, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        return button
    }()
    
    var emptySourceImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var emptySourceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = UIColor.cn_gray1
        label.textAlignment = .center
        return label
    }()
    
    var emptySourceDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = UIColor.cn_gray1
        label.textAlignment = .center
        return label
    }()
    
    init(title: String, buttonTitle: String?, emptyImage: UIImage?, emptyTitle: String?, emptyDescription: String?) {
        super.init(frame: .zero)
        
        backgroundColor = .appBackground
        clipsToBounds = false
        layer.masksToBounds = false
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .horizontal)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        titleLabel.text = title.uppercased()
        
        var lastElement: UIView = titleLabel
        if let buttonTitle = buttonTitle {
            addSubview(actionButton)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -16).isActive = true
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
            actionButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
            actionButton.setTitle(buttonTitle, for: .normal)
        }
        
        if let emptyImage = emptyImage {
            addSubview(emptySourceImageView)
            emptySourceImageView.translatesAutoresizingMaskIntoConstraints = false
            emptySourceImageView.topAnchor.constraint(equalTo: lastElement.bottomAnchor, constant: 30).isActive = true
            emptySourceImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            emptySourceImageView.widthAnchor.constraint(equalToConstant: 103).isActive = true
            emptySourceImageView.heightAnchor.constraint(equalToConstant: 103).isActive = true
            emptySourceImageView.image = emptyImage
            lastElement = emptySourceImageView
        }
        
        if let emptyTitle = emptyTitle {
            addSubview(emptySourceTitleLabel)
            emptySourceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            emptySourceTitleLabel.topAnchor.constraint(equalTo: lastElement.bottomAnchor, constant: 30).isActive = true
            emptySourceTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 47).isActive = true
            emptySourceTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -47).isActive = true
            emptySourceTitleLabel.text = emptyTitle
            lastElement = emptySourceTitleLabel
        }
        
        if let emptyDescription = emptyDescription {
            addSubview(emptySourceDescriptionLabel)
            emptySourceDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            emptySourceDescriptionLabel.topAnchor.constraint(equalTo: lastElement.bottomAnchor, constant: 12).isActive = true
            emptySourceDescriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
            emptySourceDescriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
            emptySourceDescriptionLabel.text = emptyDescription
            lastElement = emptySourceDescriptionLabel
        }
        
        lastElement.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonTapped(button: UIButton) {
        if let delegate = delegate {
            delegate.genericTableHeader(self, didTap: button)
        }
    }
    
}

