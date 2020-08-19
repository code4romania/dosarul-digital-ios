//
//  RemoteSyncer.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

enum RemoteSyncerError: Error {
    case noConnection
    case invalidStationData
    case stationError(reason: APIError?)
    case noteError(reason: APIError?)
    case questionError(reason: APIError?)

    var localizedDescription: String {
        // TODO: localize
        switch self {
        case .noConnection: return "No internet connection"
        case .invalidStationData: return "Invalid station data"
        case .stationError(let reason): return "Can't save station data. \(reason?.localizedDescription ?? "")"
        case .noteError(let reason): return "Can't save note. \(reason?.localizedDescription ?? "")"
        case .questionError(let reason): return "Can't save answer to question. \(reason?.localizedDescription ?? "")"
        }
    }
}

/// Will upload unsynced data to the server
class RemoteSyncer: NSObject {
    static let shared = RemoteSyncer()
    
    static let answersSyncedNotification = Notification.Name("answersSyncedNotification")
    static let notificationAnswersKey = "answers"

    var needsSync: Bool {
        return DB.shared.needsSync
    }
    
    func syncUnsyncedData(then callback: @escaping (RemoteSyncerError?) -> Void) {
        self.uploadUnsyncAnswersAndNotes(then: callback)
    }
    
    func uploadUnsyncAnswersAndNotes(then callback: @escaping (RemoteSyncerError?) -> Void) {
        var errors = [RemoteSyncerError]()
        uploadUnsyncedNotes { [weak self] error in
            if let error = error {
                errors.append(error)
            }
            self?.uploadUnsyncedQuestions(then: { error in
                if let error = error {
                    errors.append(error)
                }
                callback(errors.first)
            })
        }
    }
    
    func uploadUnsyncedNotes(then callback: @escaping (RemoteSyncerError?) -> Void) {
        let notes = DB.shared.getUnsyncedNotes()
        var passedRequests = 0
        let totalRequests = notes.count
        guard totalRequests > 0 else {
            callback(nil)
            return
        }
        var errors: [RemoteSyncerError] = []
        
        DebugLog("Uploading \(totalRequests) notes...")
        
        for note in notes {
            guard let beneficiaryId = note.beneficiary?.id else {
                DebugLog("Note has no beneficiary")
                continue
            }
            let uploadRequest = UploadNoteRequest(
                beneficiaryId: Int(beneficiaryId),
                imageData: note.file as Data?,
                questionId: note.questionID != -1 ? Int(note.questionID) : nil,
                text: note.body ?? "")
            AppDelegate.dataSourceManager.upload(note: uploadRequest) { error in
                if let error = error {
                    errors.append(.noteError(reason: error))
                    DebugLog("Failed to uploaded note: \(error.localizedDescription)")
                } else {
                    DebugLog("Uploaded note")
                    
                    // also mark it as synced
                    note.synced = true
                    try? CoreData.save()
                }
                
                passedRequests += 1
                if passedRequests == totalRequests {
                    DebugLog("Finished upload for \(totalRequests) notes")
                    callback(errors.first)
                }
            }
        }
        
        callback(nil)
    }

    func uploadUnsyncedQuestions(then callback: @escaping (RemoteSyncerError?) -> Void) {
        let questions = DB.shared.getUnsyncedQuestions()
        var answers: [AnswerRequest] = []
        var answerRequestsByFormId = [Int: [AnswerRequest]]()
        var fillDates = [Int: Date]()
        for question in questions {
            var answerRequestsByBeneficiaryId = [Int: [AnswerOptionRequest]]()
            if let questionAnswers = question.answers?.allObjects as? [Answer] {
                for qAnswer in questionAnswers {
                    guard let beneficiaryId = qAnswer.beneficiary?.id, qAnswer.selected else { continue }
                    // TODO: what should be sent, text or inputText as the value?
                    let option = AnswerOptionRequest(id: Int(qAnswer.id), value: qAnswer.inputText)
                    if answerRequestsByBeneficiaryId[Int(beneficiaryId)] == nil {
                        answerRequestsByBeneficiaryId[Int(beneficiaryId)] = []
                    }
                    answerRequestsByBeneficiaryId[Int(beneficiaryId)]?.append(option)
                    if let fillDate = qAnswer.fillDate, fillDates[Int(question.formId)] == nil {
                        fillDates[Int(question.formId)] = fillDate
                    }
                }
            }
            for (beneficiaryId, answerRequest) in answerRequestsByBeneficiaryId {
                let answer = AnswerRequest(
                    questionId: Int(question.id),
                    beneficiaryId: beneficiaryId,
                    options: answerRequest)
                answers.append(answer)
            }
            answerRequestsByFormId[Int(question.formId)] = answers
        }
        
        guard answers.count > 0 else {
            callback(nil)
            return
        }
        
        for (formId, answers) in answerRequestsByFormId {
            let request = UploadAnswersRequest(formId: formId,
                                               completionDate: fillDates[formId],
                                               answers: answers)
            DebugLog("Uploading answers for \(answers.count) questions...")
            AppDelegate.dataSourceManager.upload(answers: request) { error in
                if let error = error {
                    DebugLog("Uploading answers failed: \(error)")
                    callback(RemoteSyncerError.questionError(reason: error))
                } else {
                    DebugLog("Uploaded answers.")
                    
                    // update the questions sync status
                    self.markQuestionsAsSynced(usingAnswers: answers)
                    
                    // notify any interested objects
                    NotificationCenter.default.post(name: RemoteSyncer.answersSyncedNotification,
                                                    object: self,
                                                    userInfo: [RemoteSyncer.notificationAnswersKey: answers])
                    
                    callback(nil)
                }
            }
        }
    }
    
    // MARK: - Internal
    
    fileprivate func markQuestionsAsSynced(usingAnswers answers: [AnswerRequest]) {
        let questionIds = answers.map { Int16($0.questionId) }
        DB.shared.setQuestionsSynced(withIds: questionIds)
    }
}
