//
//  ContactsViewModel.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 25/08/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

struct Contact {
    var name: String
    var phone: String
    var email: String
}

class ContactsViewModel: NSObject {

    let contacts = [
        Contact(name: "DGASPC Cluj Napoca", phone: "0245899899", email: "dgaspc@cluj.ro"),
        Contact(name: "Medic voluntar", phone: "0754858585", email: "mioara.craciun@gmail.com"),
        Contact(name: "Poliția locală", phone: "0256986321", email: "-")
    ]
    
}
