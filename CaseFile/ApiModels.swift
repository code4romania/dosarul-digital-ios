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

struct Patient: Codable {
    var id: Int?
    var userId: Int?
    var name: String
    var birthDate: Date
    var civilStatus: CivilStatus
    var cityId: Int
    var countyId: Int
    var gender: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "beneficiaryId"
        case userId
        case name
        case birthDate
        case civilStatus
        case cityId
        case countyId
        case gender
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
    var imageData: Data?
    var questionId: Int?
    var countyCode: String
    var pollingStationId: Int?
    var text: String
}

struct UploadAnswersRequest: Codable {
    var answers: [AnswerRequest]
}

struct AnswerRequest: Codable {
    var questionId: Int
    var countyCode: String
    var pollingStationId: Int
    var options: [AnswerOptionRequest]
    
    enum CodingKeys: String, CodingKey {
        case questionId
        case countyCode
        case pollingStationId = "pollingStationNumber"
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
    var accessToken: String?
    var expiresIn: Int?
    var error: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case error
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

struct FormSectionResponse: Codable {
    var id: Int
    var uniqueId: String
    var code: String
    var description: String
    var questions: [QuestionResponse]
}

struct QuestionResponse: Codable {
    
    enum QuestionType: Int, Codable {
        case multipleAnswers
        case singleAnswer
        case singleAnswerWithText
        case multipleAnswerWithText
    }
    
    var id: Int
    var code: String
    var questionType: QuestionType
    var text: String
    var options: [QuestionOptionResponse]
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case questionType
        case text
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

