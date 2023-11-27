//
//  ExamViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2023.
//

import Foundation

@Observable class ExamViewModel {

    // MARK: - Properties

    var coef         : Double
    var dateExecuted : Date
    var maxMark      : Int
    var sujet        : String
    var examTypeEnum : ExamTypeEnum

    // MARK: - Initializers

    internal init(
        coef         : Double = 1.0,
        dateExecuted : Date   = Date.now,
        maxMark      : Int    = 20,
        sujet        : String = "",
        examTypeEnum : ExamTypeEnum = .global
    ) {
        self.coef         = coef
        self.dateExecuted = dateExecuted
        self.maxMark      = maxMark
        self.sujet        = sujet
        self.examTypeEnum = examTypeEnum
    }

    convenience init(from exam: ExamEntity) {
        self.init()
        self.update(from: exam)
    }

    // MARK: - Methods

    func update(from exam: ExamEntity) {
        self.coef         = exam.coef
        self.dateExecuted = exam.viewDateExecuted
        self.maxMark      = Int(exam.maxMark)
        self.sujet        = exam.viewSujet
        self.examTypeEnum = exam.examTypeEnum
    }

    /// Créer une entité Exam à partir du VM et
    /// sauvegarder le veiwContext.
    func createAndSaveEntity(inClass classe: ClasseEntity) {
        switch self.examTypeEnum {
            case .global:
                ExamEntity.createGlobalExam(
                    sujet: sujet,
                    coef: coef,
                    maxMark: maxMark,
                    dateExecuted: dateExecuted,
                    pour: classe
                )

            case .multiStep:
                ExamEntity.createSteppedExam(
                    sujet: sujet,
                    coef: coef,
                    examSteps: [ ],
                    dateExecuted: dateExecuted,
                    pour: classe
                )
        }
    }
}
