//
//  ExamViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2023.
//

import Foundation

class ExamViewModel: ObservableObject {

    // MARK: - Properties

    @Published var coef         : Double = 1.0
    @Published var dateExecuted : Date   = Date.now
    @Published var maxMark      : Int    = 20
    @Published var sujet        : String = ""
    @Published var examTypeEnum : ExamTypeEnum = .global

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
                ExamManager.createGlobalExam(
                    sujet: sujet,
                    coef: coef,
                    maxMark: maxMark,
                    dateExecuted: dateExecuted,
                    pour: classe
                )

            case .multiStep:
                ExamManager.createSteppedExam(
                    sujet: sujet,
                    coef: coef,
                    examSteps: [ ],
                    dateExecuted: dateExecuted,
                    pour: classe
                )
        }
    }
}
