//
//  AddPatientViewModel.swift
//  CaseFile
//
//  Created by Andrei Bouariu on 15/06/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

typealias ClosureTypeAnyArray = ([Any]?) -> Void

class AddPatientForm: CustomStringConvertible {
    
    enum FormFieldType {
        case name
        case birthDate
        case civilStatus
        case county
        case city
        case gender
        case relationship
    }
    
    // the text above the field
    var text: String
    
    // the placeholder inside the field
    var placeholder: String
    
    // the type of field
    var fieldType: FormFieldType
    
    // the value of the field (from text field, drop down, date selector etc)
    var value: Any?
    
    var description: String {
        if let value = value as? Date {
            return timeFormatter.string(from: value)
        }
        if let value = value as? String {
            return value
        }
        if let value = value as? CustomStringConvertible {
            return value.description
        }
        return ""
    }
    
    // the data source to choose for dropdowns
    var getSource: ((ClosureTypeAnyArray?) -> ())?
    
    var isLoading = false
    
    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    init(_ text: String,
         _ placeholder: String,
         _ fieldType: FormFieldType,
         _ value: CustomStringConvertible?,
         _ getSource: ((ClosureTypeAnyArray?) -> ())?) {
        self.text = text
        self.placeholder = placeholder
        self.fieldType = fieldType
        self.value = value
        self.getSource = getSource
    }
}

class AddPatientViewModel: NSObject {
    var navigationTitle = "Title.Patients.Add".localized
    
    var fromRelationship: Bool
    
    #warning("remove test data")
    lazy var nameForm = AddPatientForm("Patients.Add.Field.Name.Title".localized,
                                               "Patients.Add.Field.Name.Description".localized,
                                               .name,
                                               "Andrei Bouariu", //nil,
                                               nil)
    
    #warning("remove test data")
    lazy var birthForm = AddPatientForm("Patients.Add.Field.Date.Title".localized,
                                                "Patients.Add.Field.Date.Description".localized,
                                                .birthDate,
                                                Date(), //nil,
                                                nil)
    
    #warning("remove")
    lazy var civilStatusForm = AddPatientForm("Patients.Add.Field.CivilStatus.Title".localized,
                                              "Patients.Add.Field.CivilStatus.Description".localized,
                                              .civilStatus,
                                              CivilStatus.notMarried, //nil,
                                              { populateCivilStatuses in
                                                populateCivilStatuses?([CivilStatus.notMarried,
                                                                        CivilStatus.married,
                                                                        CivilStatus.divorced,
                                                                        CivilStatus.widowed])
    })
    
    lazy var populateCountiesClosure: (ClosureTypeAnyArray?) -> () =
        { [weak self] populateCounties in
            guard let self = self else {
                return
            }
            self.updateSource(for: self.countyForm) { [weak self] error in
                guard let self = self else {
                    return
                }
                populateCounties?(self.availableCounties)
        }
    }
    #warning("remove test data")
    lazy var countyForm = AddPatientForm("Patients.Add.Field.County.Title".localized,
                                         "Patients.Add.Field.County.Description".localized,
                                         .county,
                                         CountyResponse(id: 0, name: "Test", code: "TEST"), // nil,
                                         populateCountiesClosure)
    
    lazy var populateCitiesClosure: (ClosureTypeAnyArray?) -> () =
        { [weak self] populateCities in
            guard let self = self else {
                return
            }
            self.updateSource(for: self.cityForm) { [weak self] error in
                guard let self = self else {
                    return
                }
                populateCities?(self.availableCities)
        }
    }
    #warning("remove test data")
    lazy var cityForm = AddPatientForm("Patients.Add.Field.City.Title".localized,
                                               "Patients.Add.Field.City.Description".localized,
                                               .city,
                                               CityResponse(id: 0, name: "Test"), //nil,
                                               populateCitiesClosure)
    
    #warning("remove test data")
    lazy var genderForm = AddPatientForm("Patients.Add.Field.Gender.Title".localized,
                                                 "Patients.Add.Field.Gender.Description".localized,
                                                 .gender,
                                                 Gender.male, // nil,
                                                 { populateGenders in
                                                    populateGenders?([Gender.male, Gender.female])
    })
    
    lazy var generalDataSource: [AddPatientForm] = [
        nameForm,
        birthForm,
        civilStatusForm,
        countyForm,
        cityForm,
        genderForm
    ]
    
    /// Be notified when the API save state has changed
    var onSaveStateChanged: (() -> Void)?
    
    /// Be notified whenever the model data changes so you can update the interface with fresh data
    var onStateChanged: (() -> Void)?
    
    fileprivate(set) var availableCounties: [CountyResponse] = LocalStorage.shared.getCounties() ?? [] {
        didSet {
            onStateChanged?()
        }
    }
    fileprivate(set) var availableCities: [CityResponse] = [] {
        didSet {
            onStateChanged?()
        }
    }
    
    /// Reference to current patient
    var patient: Patient?
    
    init(fromRelationship: Bool) {
        self.fromRelationship = fromRelationship
        super.init()
    }
    
    var canContinue: Bool {
        return self.generalDataSource.allSatisfy { $0.value != nil }
    }
    
    fileprivate(set) var isSaving: Bool = false {
        didSet {
            onSaveStateChanged?()
        }
    }
    
    func updateSource(for form: AddPatientForm, completion: @escaping (APIError?) -> ()) {
        switch form.fieldType {
        case .county:
            form.isLoading = true
            onStateChanged?()
            self.fetchCounties { [weak self] (error) in
                form.isLoading = false
                self?.onStateChanged?()
                completion(error)
            }
        case .city:
            guard let countyValue = countyForm.value as? CountyResponse else {
                completion(.generic(reason: "Validation.CountyNotSelected".localized))
                return
            }
            form.isLoading = true
            onStateChanged?()
            self.fetchCities(countyId: countyValue.id) { [weak self] (error) in
                form.isLoading = false
                self?.onStateChanged?()
                completion(error)
            }
        default:
            break
        }
    }
    
    func fetchCounties(then completion: ((APIError?) -> ())?) {
        // Attempt to retrieve counties from Local storage, otherwise API call
        if let cachedCounties = LocalStorage.shared.getCounties() {
            self.availableCounties = cachedCounties
            self.availableCities = []
            completion?(nil)
            return
        }
        APIManager.shared.fetchCounties(completion: { (counties, error) in
            if let counties = counties {
                self.availableCounties = counties
                self.availableCities = []
                LocalStorage.shared.setCounties(counties)
            }
            completion?(error)
        })
    }
    
    func fetchCities(countyId: Int, then completion: ((APIError?) -> ())?) {
        // Attempt to retrieve cities from Local storage, otherwise API call
        if let cachedCities = LocalStorage.shared.getCities(countyId: countyId) {
            self.availableCities = cachedCities
            completion?(nil)
            return
        }
        APIManager.shared.fetchCities(countyId: countyId, completion: { (cities, error) in
            if let cities = cities {
                self.availableCities = cities
                LocalStorage.shared.setCities(cities, for: countyId)
            }
            completion?(error)
        })
    }
    
    func buildForm() {
        patient = Patient(id: nil,
                          userId: nil,
                          name: nameForm.value as! String,
                          birthDate: birthForm.value as! Date,
                          civilStatus: civilStatusForm.value as! CivilStatus,
                          cityId: (cityForm.value as! CityResponse).id,
                          countyId: (countyForm.value as! CountyResponse).id,
                          gender: (genderForm.value as! Gender).rawValue)
        let object: NSArray = [patient!]
        ApplicationData.shared.setObject(object, for: .patient)
    }
    
    deinit {
        ApplicationData.shared.removeObject(for: .patient)
    }
    
}
