//
//  ApiModels.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 20/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//
//  API:
//  https://mv-mobile-test.azurewebsites.net/swagger/index.html

import Foundation

// MARK: - Requests

struct LoginRequest: Codable {
    var email: String
    var password: String
}

struct BeneficiaryRequest: Codable {
    var id: Int16?
    var userId: Int16?
    var name: String?
    var birthDate: Date?
    var civilStatus: CivilStatus
    var cityId: Int16
    var countyId: Int16
    var gender: Gender
    var formsIds: [Int]?
    var newAllocatedFormsIds: [Int]?
    var dealocatedFormsIds: [Int]?
    var isFamilyOfBeneficiaryId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "beneficiaryId"
        case userId
        case name
        case birthDate
        case civilStatus
        case cityId
        case countyId
        case gender
        case formsIds
        case newAllocatedFormsIds
        case dealocatedFormsIds
        case isFamilyOfBeneficiaryId
    }
}

struct UpdatePollingStationRequest: Codable {
    var id: Int
    var countyCode: String
    var isUrbanArea: Bool
    var leaveTime: String
    var arrivalTime: String
    var isPresidentFemale: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "idPollingStation"
        case countyCode
        case isUrbanArea = "urbanArea"
        case leaveTime = "observerLeaveTime"
        case arrivalTime = "observerArrivalTime"
        case isPresidentFemale = "isPollingStationPresidentFemale"
    }
}

struct UploadNoteRequest: Codable {
    var beneficiaryId: Int
    var imageData: Data?
    var questionId: Int?
    var text: String
}

struct UploadAnswersRequest: Codable {
    var formId: Int
    var completionDate: Date?
    var answers: [AnswerRequest]
}

struct AnswerRequest: Codable {
    var questionId: Int
    var beneficiaryId: Int
    var options: [AnswerOptionRequest]
    
    enum CodingKeys: String, CodingKey {
        case questionId
        case beneficiaryId
        case options
    }
}

struct AnswerOptionRequest: Codable {
    var id: Int
    var value: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "optionId"
        case value
    }
}

// MARK: - Responses

struct ErrorResponse: Codable {
    var error: String
}

struct LoginResponse: Codable {
    var email: String?
    var accessToken: String?
    var expiresIn: Int?
    var firstLogin: Bool?
    var error: String?

    enum CodingKeys: String, CodingKey {
        case email
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case firstLogin = "first_login"
        case error
    }
}

struct TwoFactorAuthenticationResponse: Codable {
    var success: Bool?
}

struct ResetPasswordResponse: Codable {
    var success: Bool?
}

struct BeneficiaryListResponse: Codable {
    var beneficiaries: [BeneficiaryResponse]
    var totalItems: Int
    var totalPages: Int
    var page: Int
    var pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case beneficiaries = "data"
        case totalItems
        case totalPages
        case page
        case pageSize
    }
}

struct BeneficiaryDetailedListResponse: Codable {
    var beneficiaries: [BeneficiaryDetailedResponse]
    var totalItems: Int
    var totalPages: Int
    var page: Int
    var pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case beneficiaries = "data"
        case totalItems
        case totalPages
        case page
        case pageSize
    }
}

// Beneficiary response (sometimes it has county & city identifiers and forms, other times it has county & city names).
struct BeneficiaryResponse: Codable {
    var userId: Int16?                      // received on /api/v1/beneficiary/{id}
    var id: Int16                           // always received
    var name: String                        // always received
    var civilStatus: Int16                  // always received
    var birthDate: Date?                    // received on /api/v1/beneficiary/{id}
    var age: Int16?                         // received on /api/v1/beneficiary
    var county: String?                     // received on /api/v1/beneficiary
    var city: String?                       // received on /api/v1/beneficiary
    var countyId: Int16?                    // received on /api/v1/beneficiary/{id}
    var cityId: Int16?                      // received on /api/v1/beneficiary/{id}
    var gender: Int16?                      // always received
    var familyMembers: [Int16]?             // received on /api/v1/beneficiary/{id}
    var forms: [FormBeneficiaryResponse]?   // received on /api/v1/beneficiary/{id}
    
    enum CodingKeys: String, CodingKey {
        case userId
        case id = "beneficiaryId"
        case name
        case civilStatus
        case birthDate
        case age
        case county
        case city
        case countyId
        case cityId
        case gender
        case familyMembers
        case forms
    }
}

struct BeneficiaryDetailedResponse: Codable {
    var age: Int16                              // always received on /api/v1/beneficiary/details
    var birthDate: Date                         // always received on /api/v1/beneficiary/details
    var city: String                            // always received on /api/v1/beneficiary/details
    var cityId: Int16                           // always received on /api/v1/beneficiary/details
    var civilStatus: Int16                      // always received on /api/v1/beneficiary/details
    var county: String                          // always received on /api/v1/beneficiary/details
    var countyId: Int16                         // always received on /api/v1/beneficiary/details
    var familyMembers: [FamilyMemberResponse]?  // always received on /api/v1/beneficiary/details
    var forms: [FormBeneficiaryResponse]?       // always received on /api/v1/beneficiary/details
    var gender: Int16                           // always received on /api/v1/beneficiary/details
    var id: Int16                               // always received on /api/v1/beneficiary/details
    var name: String                            // always received on /api/v1/beneficiary/details
    var userId: Int16                           // always received on /api/v1/beneficiary/details
    
    enum CodingKeys: String, CodingKey {
        case age
        case birthDate
        case city
        case cityId
        case civilStatus
        case county
        case countyId
        case familyMembers
        case forms
        case gender
        case id = "beneficiaryId"
        case name
        case userId
    }
}

struct CountyResponse: Codable, CustomStringConvertible {
    var id: Int
    var name: String
    var code: String
    
    enum CodingKeys: String, CodingKey {
        case id = "countyId"
        case code
        case name
    }
    
    var description: String {
        return name
    }
}

struct CityResponse: Codable, CustomStringConvertible {
    var id: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "cityId"
        case name
    }
    
    var description: String {
        return name
    }
}

struct FormListResponse: Codable {
    var forms: [FormResponse]

    enum CodingKeys: String, CodingKey {
        case forms = "formVersions"
    }
}

struct FormResponse: Codable {
    var id: Int
    var code: String
    var version: Int
    var description: String
//    var order: Int? - forms do not have order yet
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case version = "currentVersion"
        case description
        // case order - forms do not have order yet
    }
}

struct FamilyMemberResponse: Codable {
    var beneficiaryId: Int
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case beneficiaryId
        case name
    }
}

// Forms on GET /beneficiary/{id}
struct FormBeneficiaryResponse: Codable {
    var id: Int16
    var completionDate: Date
    var description: String
    var code: String
    var totalQuestionsNo: Int
    var questionsAnsweredNo: Int
    var userName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "formId"
        case completionDate = "date"
        case description
        case code
        case totalQuestionsNo
        case questionsAnsweredNo
        case userName
    }
}

struct FormSectionResponse: Codable {
    var sectionId: Int
    var code: String
    var description: String?
    var questions: [QuestionResponse]
    
    enum CodingKeys: String, CodingKey {
        case sectionId
        case code = "title"
        case description
        case questions
    }
}

struct QuestionResponse: Codable {
    
    enum QuestionType: Int, Codable {
        case multipleAnswers
        case singleAnswer
        case singleAnswerWithText
        case multipleAnswerWithText
        case text
        case number
        case date
    }
    
    var id: Int
    var code: String
    var questionType: QuestionType
    var text: String
    var hint: String?
    var isMandatory: Bool
    var numberOfCharacters: Int?
    var options: [QuestionOptionResponse]
    
    enum CodingKeys: String, CodingKey {
        case id = "questionId"
        case code
        case questionType
        case text
        case hint
        case isMandatory
        case numberOfCharacters = "charsNo"
        case options = "optionsToQuestions"
    }
}

struct QuestionOptionResponse: Codable {
    var id: Int
    var text: String
    var isFreeText: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "idOption"
        case text
        case isFreeText
    }
}

struct AppInformationResponse: Decodable {
    struct ResultResponse: Decodable {
        var version: String
        var releaseNotes: String
    }
    
    var resultCount: Int
    var results: [ResultResponse]
}

