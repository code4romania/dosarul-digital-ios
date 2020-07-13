//
//  TitleSubtitleTableHeader.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 09/07/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class TitleSubtitleTableHeader: UIView {

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.defaultTableHeaderText
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.defaultTableHeaderText
        return label
    }()
    
    init(title: String, description: String?) {
        super.init(frame: .zero)
        
        backgroundColor = .appBackground
        clipsToBounds = false
        layer.masksToBounds = false
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        titleLabel.text = title
        
        guard let description = description else {
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
            return
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        descriptionLabel.text = description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
