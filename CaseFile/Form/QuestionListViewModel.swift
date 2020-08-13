//
//  QuestionListViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 26/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

struct QuestionCellModel {
    var questionId: Int
    var questionCode: String
    var questionText: String
    var isAnswered: Bool
    var isSynced: Bool
    var isNoteSynced: Bool
    var hasNoteAttached: Bool
    var isMandatory: Bool
}

class QuestionListViewModel: NSObject {
    fileprivate var form: FormResponse
    fileprivate var sections: [FormSectionResponse]
    
    var title: String {
        return form.description
    }
    
    var sectionTitles: [String] {
        return sections.map { $0.code }
    }
    
    var sectionDescriptions: [String?] {
        return sections.map { $0.description }
    }
    
    var sectionIds: [Int] {
        return sections.map { $0.sectionId }
    }
    
    var formCode: String {
        return form.code
    }
    
    var formId: Int {
        return form.id
    }
    
    init?(withFormUsingId id: Int) {
        guard let form = LocalStorage.shared.getFormSummary(withId: id),
            let sections = LocalStorage.shared.loadForm(withId: form.id) else { return nil }
        self.form = form
        self.sections = sections
        super.init()
    }
    
    func updateAnswers(with formDate: Date) {
        guard let beneficiary = ApplicationData.shared.beneficiary,
            let answers = beneficiary.answers?.allObjects as? [Answer] else {
            return
        }
        for answer in answers {
            guard let answerFormId = answer.question?.sectionInfo?.form?.id,
                Int(answerFormId) == form.id else {
                    continue
            }
            answer.fillDate = formDate
        }
    }
    
    func questions(inSection section: Int) -> [QuestionCellModel] {
        guard sections.count > section else { return [] }
        let sectionInfo = DB.shared.sectionInfo(sectionId: sectionIds[section], formId: form.id)
        
        let storedQuestions = sectionInfo.questions?.allObjects as? [Question] ?? []
        let mappedQuestions = storedQuestions.reduce(into: [Int: Question]()) { $0[Int($1.id)] = $1 }
        
        return sections[section].questions.map { questionResponse -> QuestionCellModel in
            let stored = mappedQuestions[questionResponse.id]
            var answer: Answer?
            var hasNotes = false
            var allNotesSynced = false
            if let currentBeneficiary = ApplicationData.shared.beneficiary {
                let beneficiaryPredicate = NSPredicate(format: "beneficiary == %@ AND question.id == %d", currentBeneficiary, questionResponse.id)
                answer = stored?.answers?.filtered(using: beneficiaryPredicate).first as? Answer

                let beneficiaryNotes = currentBeneficiary.notes?.allObjects as? [Note]
                if let questionNotes = beneficiaryNotes?.filter({ Int($0.questionID) == questionResponse.id }) {
                    hasNotes = questionNotes.count > 0
                    allNotesSynced = questionNotes.allSatisfy({ $0.synced })
                }
            }
            
            return QuestionCellModel(
                questionId: questionResponse.id,
                questionCode: questionResponse.code,
                questionText: questionResponse.text,
                isAnswered: answer != nil,
                isSynced: answer?.synced ?? false,
                isNoteSynced: allNotesSynced,
                hasNoteAttached: hasNotes,
                isMandatory: questionResponse.isMandatory)
        }
    }
    
    func indexPath(ofQuestionWithId questionId: Int) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            for (questionIndex, question) in section.questions.enumerated() {
                if question.id == questionId {
                    return IndexPath(row: questionIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
    
}
