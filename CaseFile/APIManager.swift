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
    
    /// For unit testing
    var expectedStatusCode: Int? { get set }
    var expectedIndex: Int? { get set }
    
    /// General requests
    /// POST /api/v1/access/authorize
    func login(email: String,
               password: String,
               completion: ((LoginResponse?, APIError?) -> Void)?)
    
    /// POST /api/v1/access/verify
    func verify2FA(code: String, completion: ((TwoFactorAuthenticationResponse?, APIError?) -> Void)?)
    
    /// POST /api/v1/access/resend
    func resend2FA(completion: ((APIError?) -> Void)?)
    
    /// POST /api/v1/user/reset
    func resetPassword(password: String, confirmPassword: String, completion: ((APIError?) -> Void)?)
    
    /// GET /api/v1/county
    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?)
    
    /// GET /api/v1/county/{id}/cities
    func fetchCities(countyId: Int, completion: (([CityResponse]?, APIError?) -> Void)?)
    
    /// Beneficiaries requests
    /// GET /api/v1/beneficiary
    func fetchBeneficiaries(completion:(([BeneficiaryDetailedResponse]?, APIError?) -> Void)?)
    
    /// GET /api/v1/beneficiary/{id}
    func fetchBeneficiary(beneficiaryId: Int, completion:((BeneficiaryResponse?, APIError?) -> Void)?)
    
    /// POST or PUT /api/v1/beneficiary
    func createOrUpdateBeneficiary(_ beneficiary: BeneficiaryRequest, isNew: Bool, completion: ((Int?, APIError?) -> Void)?)
    
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
    
    /// POST /api/v1/beneficiary/sendFile
    func sendForm(beneficiaryId: Int, completion: ((Bool, APIError?) -> Void)?)
    
}

// remove extension after all methods are implemented in all conforming classes
extension APIManagerType {
    
    /// POST /api/v1/access/authorize
    func login(email: String,
               password: String,
               completion: ((LoginResponse?, APIError?) -> Void)?) { }
    
    /// POST /api/v1/access/verify
    func verify2FA(code: String, completion: ((TwoFactorAuthenticationResponse?, APIError?) -> Void)?) { }
    
    /// POST /api/v1/access/resend
    func resend2FA(completion: ((APIError?) -> Void)?) { }
    
    /// POST /api/v1/user/reset
    func resetPassword(password: String, confirmPassword: String, completion: ((APIError?) -> Void)?) { }
    
    /// GET /api/v1/county
    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?) { }
    
    /// GET /api/v1/county/{id}/cities
    func fetchCities(countyId: Int, completion: (([CityResponse]?, APIError?) -> Void)?) { }
    
    /// GET /api/v1/beneficiary/{id}
    func fetchBeneficiary(beneficiaryId: Int, completion:((BeneficiaryResponse?, APIError?) -> Void)?) { }
    
    /// POST or PUT /api/v1/beneficiary
    func createOrUpdateBeneficiary(_ beneficiary: BeneficiaryRequest, isNew: Bool, completion: ((Int?, APIError?) -> Void)?) { }
    
    func upload(pollingStation: UpdatePollingStationRequest,
                completion: ((APIError?) -> Void)?) { }
    
    func upload(note: UploadNoteRequest,
                completion: ((APIError?) -> Void)?) { }
    
    func upload(answers: UploadAnswersRequest,
                completion: ((APIError?) -> Void)?) { }
    
    /// POST /api/v1/beneficiary/sendFile
    func sendForm(beneficiaryId: Int, completion: ((Bool, APIError?) -> Void)?) { }
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
    
    var expectedStatusCode: Int?
    var expectedIndex: Int?
    
    /// Use this to format dates to and from the API
    lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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
    
    func verify2FA(code: String, completion: ((TwoFactorAuthenticationResponse?, APIError?) -> Void)?) {
        let url = ApiURL.verify2FA.url()
        let headers = authorizationHeaders()
        let request = TwoFactorAuthenticationRequest(token: code)
        let parameters = encodableToParamaters(request)
        
        Alamofire
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    do {
                        let response2FA = try JSONDecoder().decode(TwoFactorAuthenticationResponse.self, from: data)
                        completion?(response2FA, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func resend2FA(completion: ((APIError?) -> Void)?) {
        let url = ApiURL.resend2FA.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    completion?(nil)
                } else {
                    completion?(.incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func resetPassword(password: String, confirmPassword: String, completion: ((APIError?) -> Void)?) {
        let url = ApiURL.resetPassword.url()
        let headers = authorizationHeaders()
        let request = ResetPasswordRequest(newPassword: password, newPasswordConfirmation: confirmPassword)
        let parameters = encodableToParamaters(request)
        
        Alamofire
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    completion?(nil)
                } else {
                    completion?(.incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.county.url()
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
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
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
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchBeneficiaries(completion: (([BeneficiaryDetailedResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.beneficiariesDetailed.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(self.apiDateFormatter)
                        let beneficiaries = try decoder.decode(BeneficiaryDetailedListResponse.self,
                                                               from: data)
                        completion?(beneficiaries.beneficiaries, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
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
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(self.apiDateFormatter)
                        let beneficiary = try decoder.decode(BeneficiaryResponse.self, from: data)
                        completion?(beneficiary, nil)
                    } catch {
                        completion?(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func createOrUpdateBeneficiary(_ beneficiary: BeneficiaryRequest,
                                   isNew: Bool,
                                   completion: ((Int?, APIError?) -> Void)?) {
        let url = ApiURL.beneficiaries.url()
        let headers = authorizationHeaders()
        
        let parameters = encodableToParamaters(beneficiary)
        
        Alamofire
            .request(url, method: isNew ? .post : .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .response { response in
                let statusCode = response.response?.statusCode
                if statusCode == 200,
                    let data = response.data {
                    if isNew {
                        if let beneficiaryStringId = String(data: data, encoding: .utf8),
                            let beneficiaryId = Int(beneficiaryStringId) {
                            completion?(beneficiaryId, nil)
                        } else {
                            completion?(nil, .generic(reason: "Unknown reason"))
                        }
                    } else {
                        if let beneficiaryId = beneficiary.id,
                            let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)?.boolValue,
                            result == true {
                            completion?(Int(beneficiaryId), nil)
                        } else {
                            completion?(nil, .generic(reason: "Unknown reason"))
                        }
                    }
                } else if statusCode == 401 {
                    completion?(nil, .unauthorized)
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
                } else {
                    completion?(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchForms(completion: (([FormResponse]?, APIError?) -> Void)?) {
        let url = ApiURL.forms.url()
        
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
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
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
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
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
        
        let url = ApiURL.county.url()
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
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
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
            "BeneficiaryId": String(note.beneficiaryId),
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
                            AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
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
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(self.apiDateFormatter)
        let body = try! encoder.encode(answers)
        
        Alamofire
            .upload(body, to: url, method: .post, headers: headers)
            .response { response in
                if response.response?.statusCode == 200 {
                    completion?(nil)
                } else if response.response?.statusCode == 401 {
                    completion?(.unauthorized)
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
                } else {
                    completion?(.incorrectFormat(reason: "Unknown reason (code: \(response.response?.statusCode ?? -1))"))
                }
        }
    }
    
    func sendForm(beneficiaryId: Int, completion: ((Bool, APIError?) -> Void)?) {
        let url = ApiURL.sendForm.url()
        let auth = authorizationHeaders()
        let parameters = ["beneficiaryId": beneficiaryId]
        
        Alamofire
            .request(url, method: .post, parameters: parameters, encoding: URLEncoding.queryString, headers: auth)
            .response { response in
                if response.response?.statusCode == 200,
                    let data = response.data,
                    let success = try? JSONDecoder().decode(Bool.self, from: data) {
                    completion?(success, nil)
                } else if response.response?.statusCode == 401 {
                    completion?(false, .unauthorized)
                    AppRouter.shared.logout(message: APIError.unauthorized.localizedDescription)
                } else {
                    completion?(false, .incorrectFormat(reason: "Unknown reason"))
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
        encoder.dateEncodingStrategy = .formatted(self.apiDateFormatter)
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
    
    var expectedStatusCode: Int?
    var expectedIndex: Int?
    
    /// Use this to format dates to and from the API
    lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func login(email: String, password: String, completion: ((LoginResponse?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "LoginResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            var loginResponse = try JSONDecoder().decode(Array<LoginResponse>.self, from: data)[expectedIndex ?? 0]
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
    }
    
    func verify2FA(code: String, completion: ((TwoFactorAuthenticationResponse?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "2FAResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            let twoFAResponse = try JSONDecoder().decode(Array<TwoFactorAuthenticationResponse>.self, from: data)[expectedIndex ?? 0]
                completion?(twoFAResponse, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }

    func resend2FA(completion: ((APIError?) -> Void)?) {
        expectedStatusCode = expectedStatusCode ?? 200
        guard let data = fromFile(filename: "2FARetryResponse", ext: "json", statusCode: expectedStatusCode!) else {
            completion?(.incorrectFormat(reason: "Missing mock file"))
            return
        }
        if expectedStatusCode == 200 {
            completion?(nil)
        } else {
            completion?(.generic(reason: String(data: data, encoding: .utf8)))
        }
    }

    func resetPassword(password: String, confirmPassword: String, completion: ((APIError?) -> Void)?) {
        expectedStatusCode = expectedStatusCode ?? 200
        guard let data = fromFile(filename: "ResetPasswordResponse", ext: "json", statusCode: expectedStatusCode!) else {
            completion?(.incorrectFormat(reason: "Missing mock file"))
            return
        }
        if expectedStatusCode == 200 {
            completion?(nil)
        } else {
            completion?(.generic(reason: String(data: data, encoding: .utf8)))
        }
    }

    func fetchCounties(completion: (([CountyResponse]?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "CountyResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            let countyResponse = try JSONDecoder().decode(Array<[CountyResponse]>.self, from: data)[expectedIndex ?? 0]
            completion?(countyResponse, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }

    func fetchCities(countyId: Int, completion: (([CityResponse]?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "CitiesResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            let cityResponse = try JSONDecoder().decode(Array<[CityResponse]>.self, from: data)[expectedIndex ?? 0]
            completion?(cityResponse, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }
    
    func fetchBeneficiaries(completion:(([BeneficiaryDetailedResponse]?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "BeneficiariesResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(self.apiDateFormatter)
            let beneficiaries = try decoder.decode(Array<BeneficiaryDetailedListResponse>.self, from: data)[expectedIndex ?? 0]
            completion?(beneficiaries.beneficiaries, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }
    
    func fetchBeneficiary(beneficiaryId: Int, completion: ((BeneficiaryResponse?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "BeneficiaryResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(self.apiDateFormatter)
            let beneficiary = try decoder.decode(Array<BeneficiaryResponse>.self, from: data)[expectedIndex ?? 0]
            completion?(beneficiary, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }
    
    func createOrUpdateBeneficiary(_ beneficiary: BeneficiaryRequest, isNew: Bool, completion: ((Int?, APIError?) -> Void)?) {
        let createData = fromFile(filename: "CreateBeneficiaryResponse", ext: "json", statusCode: expectedStatusCode ?? 200)
        guard createData != nil, isNew else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        let updateData = fromFile(filename: "UpdateBeneficiaryResponse", ext: "json", statusCode: expectedStatusCode ?? 200)
        guard updateData != nil, !isNew else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        guard let data = createData ?? updateData else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        if expectedStatusCode == 200 {
            if isNew {
                if let beneficiaryStringId = String(data: data, encoding: .utf8),
                    let beneficiaryId = Int(beneficiaryStringId) {
                    completion?(beneficiaryId, nil)
                } else {
                    completion?(nil, .generic(reason: "Unknown reason"))
                }
            } else {
                if let beneficiaryId = beneficiary.id,
                    let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)?.boolValue,
                    result == true {
                    completion?(Int(beneficiaryId), nil)
                } else {
                    completion?(nil, .generic(reason: "Unknown reason"))
                }
            }
        } else if expectedStatusCode == 401 {
            completion?(nil, .unauthorized)
        } else {
            completion?(nil, .incorrectFormat(reason: "Unknown reason"))
        }
    }
    
    func fetchForms(completion: (([FormResponse]?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "FormsResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        do {
            let response = try JSONDecoder().decode(Array<FormListResponse>.self, from: data)[expectedIndex ?? 0]
            completion?(response.forms, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }
    
    func fetchForm(formId: Int, completion: (([FormSectionResponse]?, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "FormResponse\(formId)", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(nil, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        
        do {
            let response = try JSONDecoder().decode(Array<[FormSectionResponse]>.self, from: data)[expectedIndex ?? 0]
            completion?(response, nil)
        } catch {
            completion?(nil, .incorrectFormat(reason: error.localizedDescription))
        }
    }

    func sendForm(beneficiaryId: Int, completion: ((Bool, APIError?) -> Void)?) {
        guard let data = fromFile(filename: "SendFormResponse", ext: "json", statusCode: expectedStatusCode ?? 200) else {
            completion?(false, .incorrectFormat(reason: "Missing mock file"))
            return
        }
        
        do {
            let response = try JSONDecoder().decode(Array<Bool>.self, from: data)[expectedIndex ?? 0]
            completion?(response, response ? nil : .generic(reason: ""))
        } catch {
            completion?(false, .incorrectFormat(reason: error.localizedDescription))
        }
    }
}

extension APIMock {
    func fromFile(filename: String, ext: String, statusCode: Int) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext),
            let data = try? Data(contentsOf: url),
            let fullContents = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let statusCodeContents = fullContents[String(statusCode)] else {
                return nil
        }
        if JSONSerialization.isValidJSONObject(statusCodeContents) {
            if let responseData = try? JSONSerialization.data(withJSONObject: statusCodeContents,
                                                              options: .prettyPrinted) {
                return responseData
            }
        }
        if let responseString = statusCodeContents as? String {
            return Data(responseString.utf8)
        }
        return nil
    }
}
