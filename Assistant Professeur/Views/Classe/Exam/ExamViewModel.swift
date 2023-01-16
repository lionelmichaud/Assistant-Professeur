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

    // MARK: - Initializers

    internal init(
        coef         : Double = 1.0,
        dateExecuted : Date   = Date.now,
        maxMark      : Int    = 20,
        sujet        : String = ""
    ) {
        self.coef         = coef
        self.dateExecuted = dateExecuted
        self.maxMark      = maxMark
        self.sujet        = sujet
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
    }

    /// Créer une entité Exam à partir du VM et
    /// sauvegarder le veiwContext.
    func createAndSaveEntity(inClass classe: ClasseEntity) {
        let exam = ExamManager.createExam(pour: classe)
        // Classe d'appartenance.
        // mandatory
        exam.classe = classe

        exam.coef         = coef
        exam.dateExecuted = dateExecuted
        exam.maxMark      = Int16(maxMark)
        exam.sujet        = sujet

        try? ClasseEntity.saveIfContextHasChanged()
    }
}
