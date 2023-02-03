//
//  ExamManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/01/2023.
//

import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ExamManager"
)

/// Gestionnaire d'Evaluation pour une classe d'élèves
enum ExamManager {
    /// Créer une nouvelle évaluation **globale** pour une classe d'élèves
    ///
    /// Crée une note par défaut pour chaque élève de la classe.
    /// - Parameter classe: Classe pour laquelle l'évaluation est créée
    /// - Returns: L'évaluation créée.
    ///
    /// - Important: The context has changes and **is commited**
    @discardableResult
    static func createGlobalExam(
        sujet: String = "",
        coef: Double = 1.0,
        maxMark: Int = 20,
        dateExecuted: Date = Date.now,
        pour classe: ClasseEntity
    ) -> ExamEntity {
        let exam = ExamEntity.create()
        exam.classe = classe

        exam.setExamTypeEnum(.global)
        exam.setSujet(sujet)
        exam.setCoef(coef)
        exam.setDateExecuted(dateExecuted)
        exam.maxMark = Int16(maxMark)

        let eleves = classe.allEleves
        eleves.forEach { eleve in
            createGlobalMark(of: eleve, for: exam)
        }

        try? ExamEntity.saveIfContextHasChanged()

        return exam
    }

    /// Créer une nouvelle évaluation **échelonnée** pour une classe d'élèves
    ///
    /// Crée une note par défaut pour chaque élève de la classe.
    /// - Parameter classe: Classe pour laquelle l'évaluation est créée
    /// - Returns: L'évaluation créée.
    ///
    /// - Important: The context has changes and **is commited**
    @discardableResult
    static func createSteppedExam(
        sujet: String = "",
        coef: Double = 1.0,
        examSteps: [ExamStep] = [],
        dateExecuted: Date = Date.now,
        pour classe: ClasseEntity
    ) -> ExamEntity {
        // TODO: - Faire ce qu'il faut quand un nouvel élève est ajouté à une classe
        let exam = ExamEntity.create()
        exam.classe = classe

        exam.setExamTypeEnum(.multiStep)
        exam.setSujet(sujet)
        exam.setCoef(coef)
        exam.setDateExecuted(dateExecuted)
        exam.setSteps(examSteps)
        // la note maxi est la somme des points maxi de chaque étape
        exam.maxMark = Int16(examSteps.sum(for: \.points))

        let eleves = classe.allEleves
        eleves.forEach { eleve in
            createSteppedMark(of: eleve, for: exam)
        }

        try? ExamEntity.saveIfContextHasChanged()

        return exam
    }

    @discardableResult
    static func createGlobalMark(
        of eleve: EleveEntity,
        for exam: ExamEntity
    ) -> MarkEntity {
        let mark = MarkEntity.create()
        mark.setExamTypeEnum(.global)
        mark.eleve = eleve
        mark.exam = exam
        return mark
    }

    @discardableResult
    static func createSteppedMark(
        of eleve: EleveEntity,
        for exam: ExamEntity
    ) -> MarkEntity {
        let mark = MarkEntity.create()
        mark.setExamTypeEnum(.multiStep)
        mark.eleve = eleve
        mark.exam = exam

        // initialiser les notes de chaque étapes de l'évaluation
        let nbOfSteps = exam.viewSteps.count
        mark.viewStepsMarks = [Double].init(repeating: 0.0, count: nbOfSteps)

        return mark
    }
}
