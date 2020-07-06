//
//  APIManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

protocol APIManagerType: NSObject {
    var apiDateFormatter: DateFormatter { get }
    
    /// General requests
    /// POST /api/v1/access/authorize
    func login(email: String,
               password: String,
               completion: ((LoginResponse?, APIError?) -> Void)?)
    
    /// GET /api/v1/county
    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?)
    
    /// GET /api/v1/county/{id}/cities
    func fetchCities(countyId: Int, completion: (([CityResponse]?, APIError?) -> Void)?)
    
    /// Beneficiaries requests
    /// GET /api/v1/beneficiary
    func fetchBeneficiaries(completion:(([BeneficiaryResponse]?, APIError?) -> Void)?)
    
    /// GET /api/v1/beneficiary/{id}
    func fetchBeneficiary(beneficiaryId: Int, completion:((BeneficiaryResponse?, APIError?) -> Void)?)
    
    /// POST /api/v1/beneficiary
    func createBeneficiary(_ beneficiary: BeneficiaryRequest, completion: ((Int?, APIError?) -> Void)?)
    
    /// Form requests
    /// GET /api/v1/form
    func fetchForms(completion: (([FormResponse]?, APIError?) -> Void)?)
    
    /// GET /api/v1/form/{id}
    func fetchForm(formId: Int,
                   completion: (([FormSectionResponse]?, APIError?) -> Void)?)
    
    func upload(pollingStation: UpdatePollingStationRequest,
                completion: ((APIError?) -> Void)?)
    
    func upload(note: UploadNoteRequest,
                completion: ((APIError?) -> Void)?)
    
    func upload(answers: UploadAnswersRequest,
                completion: ((APIError?) -> Void)?)
    
}

// remove extension after all methods are implemented in all conforming classes
extension APIManagerType {
    
    /// GET /api/v1/county
    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?) { }
    
    /// GET /api/v1/county/{id}/cities
    func fetchCities(countyId: Int, completion: (([CityResponse]?, APIError?) -> Void)?) { }
    
    /// GET /api/v1/beneficiary/{id}
    func fetchBeneficiary(beneficiaryId: Int, completion:((BeneficiaryResponse?, APIError?) -> Void)?) { }
    
    /// POST /api/v1/beneficiary
    func createBeneficiary(_ beneficiary: BeneficiaryRequest, completion: ((Int?, APIError?) -> Void)?) { }
    
    /// Form requests
    /// GET /api/v1/form
    func fetchForms(completion: (([FormResponse]?, APIError?) -> Void)?) { }
    
    /// GET /api/v1/form/{id}
    func fetchForm(formId: Int,
                   completion: (([FormSectionResponse]?, APIError?) -> Void)?) { }
    
    func upload(pollingStation: UpdatePollingStationRequest,
                completion: ((APIError?) -> Void)?) { }
    
    func upload(note: UploadNoteRequest,
                completion: ((APIError?) -> Void)?) { }
    
    func upload(answers: UploadAnswersRequest,
                completion: ((APIError?) -> Void)?) { }
}

enum APIError: Error {
    case unauthorized
    case incorrectFormat(reason: String?)
    case generic(reason: String?)
    case loginFailed(reason: String?)
    
    var localizedDescription: String {
        var isDebug = false
        #if DEBUG
        isDebug = true
        #endif
        switch self {
        case .unauthorized: return "Error.TokenExpired".localized
        case .incorrectFormat(let reason): return "Error.Server".localized + (isDebug ? " (\(reason ?? ""))" : "")
        case .generic(let reason): return reason ?? "Error_Unknown".localized
        case .loginFailed(let reason): return reason ?? "LoginError_Unknown".localized
        }
    }
}

class APIManager: NSObject, APIManagerType {
    static let shared: APIManagerType = APIManager()
    
    /// Use this to format dates to and from the API
    lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func login(email: String, password: String, completion: ((LoginResponse?, APIError?) -> Void)?) {
        if let errorMessage = checkConnectionError() {
            completion?(nil, .generic(reason: errorMessage))
            return
        }
        
        let url = ApiURL.login.url()
        let request = LoginRequest(email: email, password: password)
        let parameters = encodableToParamaters(request)
        
        Alamofire
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .response { response in
            if let data = response.data {
                do {
                    var loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    if loginResponse.accessToken != nil {
                        // login response doesn't contain an email so we'll add it here
                        loginResponse.email = email
                        completion?(loginResponse, nil)
                    } else {
                        completion?(nil, .loginFailed(reason: loginResponse.error))
                    }
                } catch {
                    completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                }
            } else {
                completion?(nil, .loginFailed(reason: "No data received"))
            }
        }
    }
    
    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.pollingStationList.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    do {
                        let stations = try JSONDecoder().decode([CountyResponse].self, from: data)
                        completion?(stations, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchCities(countyId: Int, completion: (([CityResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.city(id: countyId).url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    do {
                        let cities = try JSONDecoder().decode([CityResponse].self, from: data)
                        completion?(cities, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchBeneficiaries(completion: (([BeneficiaryResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.beneficiaries.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    do {
                        let beneficiaries = try JSONDecoder().decode(BeneficiaryListResponse.self, from: data)
                        completion?(beneficiaries.beneficiaries, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchBeneficiary(beneficiaryId: Int, completion: ((BeneficiaryResponse?, APIError?) -> Void)?) {
        let url = ApiURL.beneficiary(id: beneficiaryId).url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    do {
                        let beneficiary = try JSONDecoder().decode(BeneficiaryResponse.self, from: data)
                        completion?(beneficiary, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func createBeneficiary(_ beneficiary: BeneficiaryRequest, completion: ((Int?, APIError?) -> Void)?) {
        let url = ApiURL.beneficiaries.url()
        let headers = authorizationHeaders()
        
        let parameters = encodableToParamaters(beneficiary)
        
        Alamofire
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    if let beneficiaryStringId = String(data: data, encoding: .utf8),
                        let beneficiaryId = Int(beneficiaryStringId) {
                        completion?(beneficiaryId, nil)
                    } else {
                        completion?(nil, .generic(reason: "Unknown reason"))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchForms(completion: (([FormResponse]?, APIError?) -> Void)?) {
        var url = ApiURL.forms.url()
//        if RemoteConfigManager.shared.value(of: .filterDiasporaForms).boolValue {
//            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
//                urlComponents.queryItems = [URLQueryItem(name: "diaspora", value: "\(diaspora ? "true" : "false")")]
//                if let newURL = urlComponents.url {
//                    url = newURL
//                }
//            }
//        }
        
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
            
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode(FormListResponse.self, from: data)
                        completion?(response.forms, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if response.response?.statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchForm(formId: Int, completion: (([FormSectionResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.form(id: formId).url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
            
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode([FormSectionResponse].self, from: data)
                        completion?(response, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if response.response?.statusCode == 401 {
                    completion?(nil, .unauthorized)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func upload(pollingStation: UpdatePollingStationRequest, completion: ((APIError?) -> Void)?) {
        if let errorMessage = checkConnectionError() {
            completion?(.generic(reason: errorMessage))
            return
        }
        
        let url = ApiURL.pollingStation.url()
        let auth = authorizationHeaders()
        let headers = requestHeaders(withAuthHeaders: auth)
        let body = try! JSONEncoder().encode(pollingStation)
        
        Alamofire
            .upload(body, to: url, method: .post, headers: headers)
            .response { response in
                if response.response?.statusCode == 200 {
                    completion?(nil)
                } else if response.response?.statusCode == 401 {
                    completion?(.unauthorized)
                } else {
                    completion?(.incorrectFormat(reason: "Response code \(response.response?.statusCode ?? -1)"))
                }
        }
    }
    
    func upload(note: UploadNoteRequest, completion: ((APIError?) -> Void)?) {
        let url = ApiURL.uploadNote.url()
        let auth = authorizationHeaders()
        let headers = requestHeaders(withAuthHeaders: auth)

        var parameters: [String: String] = [
            "CountyCode": note.countyCode,
            "PollingStationNumber": String(note.pollingStationId ?? -1),
            "Text": note.text
        ]
        if let questionId = note.questionId {
            parameters["QuestionId"] = String(questionId)
        }

        let threshold = SessionManager.multipartFormDataEncodingMemoryThreshold
        
        Alamofire
            .upload(multipartFormData: { (multipart) in
                for (key, param) in parameters {
                    multipart.append(param.data(using: String.Encoding.utf8)!, withName: key)
                }
                if let imageData = note.imageData {
                    multipart.append(imageData, withName: "file", fileName: "newImage.jpg", mimeType: "image/jpeg")
                }
            }, usingThreshold: threshold, to: url, method: .post, headers: headers, encodingCompletion: { result in
                switch result {
                case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                    request.response { response in
                        if response.response?.statusCode == 200 {
                            completion?(nil)
                        } else if response.response?.statusCode == 401 {
                            completion?(.unauthorized)
                        } else {
                            completion?(.incorrectFormat(reason: "Unknown reason"))
                        }
                    }
                case .failure(let error):
                    completion?(.generic(reason: error.localizedDescription))
                }
        })
    }
    
    func upload(answers: UploadAnswersRequest, completion: ((APIError?) -> Void)?) {
        let url = ApiURL.uploadAnswer.url()
        let auth = authorizationHeaders()
        let headers = requestHeaders(withAuthHeaders: auth)
        let body = try! JSONEncoder().encode(answers)
        
        Alamofire
            .upload(body, to: url, method: .post, headers: headers)
            .response { response in
                if response.response?.statusCode == 200 {
                    completion?(nil)
                } else if response.response?.statusCode == 401 {
                    completion?(.unauthorized)
                } else {
                    completion?(.incorrectFormat(reason: "Unknown reason (code: \(response.response?.statusCode ?? -1))"))
                }
        }
    }
    
    private func checkConnectionError() -> String? {
        ReachabilityManager.shared.isReachable ? nil : "Error.InternetConnection".localized
    }
    
}

// MARK: - Helpers

extension APIManager {
    fileprivate func encodableToParamaters<T: Encodable>(_ encodable: T) -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try! encoder.encode(encodable)
        return try! JSONSerialization.jsonObject(with: body, options: []) as! [String: Any]
    }
    
    fileprivate func authorizationHeaders() -> [String: String] {
        if let token = AccountManager.shared.accessToken {
            return ["Authorization": "Bearer " + token]
        } else {
            return [:]
        }
    }
    
    fileprivate func requestHeaders(withAuthHeaders authHeaders: [String: String]?) -> [String: String] {
        var headers: [String: String] = ["Content-Type": "application/json"]
        if let authHeaders = authHeaders {
            for (key, value) in authHeaders {
                headers[key] = value
            }
        }
        return headers
    }
}


class APIMock: NSObject, APIManagerType {
    static let shared: APIManagerType = APIMock()
    
    /// Use this to format dates to and from the API
    lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func login(email: String, password: String, completion: ((LoginResponse?, APIError?) -> Void)?) {
//        completion?(nil)
    }
    
    func fetchBeneficiaries(completion:(([BeneficiaryResponse]?, APIError?) -> Void)?) {
//        guard let response = fromFile(filename: "PatientsResponse", ext: "json", statusCode: 200) else {
//            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
//            return
//        }
//        if response.response?.statusCode == 200,
//            let data = response.data {
//            do {
//                let response = try JSONDecoder().decode([BeneficiaryResponse].self, from: data)
//                completion?(response, nil)
//            } catch {
//                completion?(nil, .incorrectFormat(reason: error.localizedDescription))
//            }
//        } else if response.response?.statusCode == 401 {
//            completion?(nil, .unauthorized)
//        } else {
//            completion?(nil, .incorrectFormat(reason: "Unknown reason (code: \(response.response?.statusCode ?? -1))"))
//        }
    }
    
}

extension APIMock {
    struct R {
        struct Response {
            var statusCode: Int
        }
        var data: Data?
        var response: Response?
    }
    
    func fromFile(filename: String, ext: String, statusCode: Int) -> R? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            return nil;
        }
        return R(data: try? Data(contentsOf: url), response: R.Response(statusCode: statusCode))
    }
}
