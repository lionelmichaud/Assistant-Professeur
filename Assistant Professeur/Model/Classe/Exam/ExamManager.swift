//
//  ExamManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/01/2023.
//

import Foundation
import os

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "ExamManager")

/// Gestionnaire d'Evaluation pour une classe d'élèves
struct ExamManager {

    /// Créer une nouvelle évaluation **globale** pour une classe d'élèves
    ///
    /// Crée une note par défaut pour chaque élève de la classe.
    /// - Parameter classe: Classe pour laquelle l'évaluation est créée
    /// - Returns: L'évaluation créée.
    ///
    /// - Important: The context has changes and **is commited**
    @discardableResult static func createGlobalExam(
        sujet        : String = "",
        coef         : Double = 1.0,
        maxMark      : Int    = 20,
        dateExecuted : Date   = Date.now,
        pour classe  : ClasseEntity
    ) -> ExamEntity {
        // TODO: - Faire ce qu'il faut quand un nouvel élève est ajouté à une classe
        let exam = ExamEntity.create()
        exam.classe = classe

        let eleves = classe.allEleves
        eleves.forEach { eleve in
            let mark = MarkEntity.create()
            mark.eleve = eleve
            mark.exam = exam
        }

        exam.sujet        = sujet
        exam.coef         = coef
        exam.maxMark      = Int16(maxMark)
        exam.dateExecuted = dateExecuted

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
    @discardableResult static func createSteppedExam(
        sujet        : String = "",
        coef         : Double = 1.0,
        examSteps    : [ExamStep] = [ ],
        dateExecuted : Date   = Date.now,
        pour classe  : ClasseEntity
    ) -> ExamEntity {
        // TODO: - Faire ce qu'il faut quand un nouvel élève est ajouté à une classe
        let exam = ExamEntity.create()
        exam.classe = classe

        exam.sujet        = sujet
        exam.coef         = coef
        exam.dateExecuted = dateExecuted
        exam.steps        = examSteps
        // la note maxi est la somme des points maxi de chaque étape
        exam.maxMark      = Int16(examSteps.sum(for: \.points))

        let eleves = classe.allEleves
        eleves.forEach { eleve in
            let mark = MarkEntity.create()
            mark.eleve = eleve
            mark.exam = exam
        }

        try? ExamEntity.saveIfContextHasChanged()

        return exam
    }
}
