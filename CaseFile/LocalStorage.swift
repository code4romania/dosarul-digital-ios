//
//  LocalStorage.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 21/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum LocalFilename {
    case counties
    case cities(countyId: Int)
    case forms
    case form(id: Int)
    
    var fullName: String {
        var name: String
        switch self {
        case .counties:
            name = "counties"
        case .cities(let countyId):
            name = "cities-\(countyId)"
        case .forms:
            name = "forms"
        case .form(let id):
            name = "form-details-\(id)"
        }
        return name + ".json"
    }
}

protocol LocalStorageType: NSObject {
    
    func getCounties() -> [CountyResponse]?
    func setCounties(_ counties: [CountyResponse]?)
    func getCities(countyId: Int) -> [CityResponse]?
    func setCities(_ cities: [CityResponse]?, for countyId: Int)
    var forms: [FormResponse]? { set get }
    
    func getCounty(withCode code: String) -> CountyResponse?
    func getFormSummary(withId id: Int) -> FormResponse?
    func loadForm(withId formId: Int) -> [FormSectionResponse]?
    func saveForm(_ form: [FormSectionResponse], withId formId: Int)
    
}

/// This class is used as an entry point for storing data that is overwritten from server.
/// The data returned by methods of this class is a replica of responses that come from the API
/// and works mainly as a cache of real data.
/// It stores the data in the cache directory as JSON files (which is exactly what comes from the server)
class LocalStorage: NSObject, LocalStorageType {
    
    static let shared: LocalStorageType = LocalStorage()
    
    // MARK: - Public
    
    func getCounties() -> [CountyResponse]? {
        return load(type: [CountyResponse].self, withFilename: .counties)
    }
    
    func setCounties(_ counties: [CountyResponse]?) {
        if let counties = counties {
            save(codable: counties, withFilename: .counties)
        } else {
            delete(fileWithName: .counties)
        }
    }
    
    func getCities(countyId: Int) -> [CityResponse]? {
        return load(type: [CityResponse].self, withFilename: .cities(countyId: countyId))
    }
    
    func setCities(_ cities: [CityResponse]?, for countyId: Int) {
        if let cities = cities {
            save(codable: cities, withFilename: .cities(countyId: countyId))
        } else {
            delete(fileWithName: .cities(countyId: countyId))
        }
    }
    
    var forms: [FormResponse]? {
        set {
            if let newValue = newValue {
                save(codable: newValue, withFilename: .forms)
            } else {
                delete(fileWithName: .forms)
            }
        } get {
            return load(type: [FormResponse].self, withFilename: .forms)
        }
    }
    
    func loadForm(withId formId: Int) -> [FormSectionResponse]? {
        return load(type: [FormSectionResponse].self, withFilename: .form(id: formId))
    }
    
    func saveForm(_ form: [FormSectionResponse], withId formId: Int) {
        save(codable: form, withFilename: .form(id: formId))
    }
    
    func getFormSummary(withId id: Int) -> FormResponse? {
        guard let forms = forms else { return nil }
        return forms.filter { $0.id == id }.first
    }
    
    func getCounty(withCode code: String) -> CountyResponse? {
        guard let counties = getCounties() else { return nil }
        return counties.filter { $0.code == code }.first
    }

    // MARK: - Internal
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate var containerDirectory: String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths.first!
    }

    fileprivate func load<T>(type: T.Type, withFilename filename: LocalFilename) -> T? where T: Decodable {
        let fileUrl = URL(fileURLWithPath: containerDirectory).appendingPathComponent(filename.fullName)
        do {
            let data = try Data(contentsOf: fileUrl)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
//            DebugLog("Error loading file at \(fileUrl): \(error.localizedDescription)")
            return nil
        }
    }
    
    fileprivate func save<T>(codable: T, withFilename filename: LocalFilename) where T: Encodable {
        let fileUrl = URL(fileURLWithPath: containerDirectory).appendingPathComponent(filename.fullName)
        do {
            let data = try JSONEncoder().encode(codable)
            try data.write(to: fileUrl)
        } catch {
            DebugLog("Error saving file to \(fileUrl): \(error.localizedDescription)")
        }
    }
    
    fileprivate func delete(fileWithName filename: LocalFilename) {
        let fileUrl = URL(fileURLWithPath: containerDirectory).appendingPathComponent(filename.fullName)
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch {
            DebugLog("Error deleting file at \(fileUrl): \(error.localizedDescription)")
        }
    }
    
}


