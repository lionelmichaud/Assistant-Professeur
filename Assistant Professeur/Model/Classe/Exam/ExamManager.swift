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

    /// Créer une nouvelle évaluation pour une classe d'élèves
    ///
    /// Crée une note par défaut pour chaque élève de la classe.
    /// - Parameter classe: Classe pour laquelle l'évaluation est créée
    /// - Returns: L'évaluation créée.
    ///
    /// - Important: The context has changes and **is commited**
    static func createExam(pour classe: ClasseEntity) -> ExamEntity {
        let exam = ExamEntity.create()
        exam.classe = classe

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
