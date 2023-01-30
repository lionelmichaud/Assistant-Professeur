//
//  Exam+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2023.
//

import CoreData
import Foundation

/// Un établissement scolaire
extension ExamEntity {
    // MARK: - Computed properties

    /// Wrapper of `examType`
    /// - Important: *Saves the context to the store after modification is done*
    var examTypeEnum: ExamTypeEnum {
        get {
            if let examType {
                return ExamTypeEnum(rawValue: examType) ?? .global
            } else {
                return .global
            }
        }
        set {
            self.examType = newValue.rawValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `sujet`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSujet: String {
        get {
            self.sujet ?? ""
        }
        set {
            self.sujet = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `dateExecuted`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDateExecuted: Date {
        get {
            self.dateExecuted ?? Date.now
        }
        set {
            self.dateExecuted = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `maxMark`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMaxMark: Int {
        get {
            switch self.examTypeEnum {
                case .global:
                    return Int(self.maxMark)
                case .multiStep:
                    print("Nombre d'étapes dans viewMaxMark \(viewSteps.count)")
                    return viewSteps.sum(for: \.points)
            }
        }
        set {
            self.maxMark = Int16(newValue)
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `coef`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewCoef: Double {
        get {
            self.coef
        }
        set {
            self.coef = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `steps`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSteps: StepsArray {
        get {
            switch self.examTypeEnum {
                case .global:
                    return [ ]
                case .multiStep:
                    print("Nombre d'étapes dans viewSteps \(steps?.count ?? 0)")
                    return (steps as? StepsArray) ?? [ ]
            }
        }
        set {
            self.steps = NSArray(array: newValue)
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Nombre d'étapes de cette évaluation.
    var nbOfSteps: Int? {
        steps?.count
    }

    /// Nombre de notes de cette évaluation.
    /// En principe, autant que d'élèves dans la classe associée à cette évaluation.
    var nbOfMarks: Int {
        Int(marksCount)
    }

    // MARK: - Methods

    /// Modifie l'attribut `examType`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setExamTypeEnum(_ newExamType: ExamTypeEnum) {
        self.examType = newExamType.rawValue
    }

    /// Modifie l'attribut `examType`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setSujet(_ sujet: String) {
        self.sujet = sujet
    }

    /// Modifie l'attribut `dateExecuted`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setDateExecuted(_ date: Date) {
        self.dateExecuted = date
    }

    /// Modifie l'attribut `coef`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setCoef(_ coef: Double) {
        self.coef = coef
    }

    /// Modifie l'attribut `steps`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setSteps(_ steps: StepsArray) {
        self.steps = NSArray(array: steps)
        print(self.steps?.count ?? "Aucune étapes dans setSteps")
    }
}

// MARK: - Extension Notes Echelonnées

extension ExamEntity {
    
}

// MARK: - Extension Core Data

extension ExamEntity: ModelEntityP {
    // MARK: - Type Computed Properties

    @Preference(\.nameSortOrder)
    private static var nameSortOrder

    // MARK: - Type Methods

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { exam in
            guard exam.classe != nil else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Computed Properties

    /// Liste des notes de l'évaluation non triées
    var allMarks: [MarkEntity] {
        if let marks {
            return (marks.allObjects as! [MarkEntity])
        } else {
            return []
        }
    }

    /// Liste des notes des élèves de la classe triése par nom des élèves.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    var marksSortedByEleveName: [MarkEntity] {
        sortedMarksByEleveName(searchString: "")
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        // self.group = ""
        //        self.fileDate = Date()
    }

    /// Retourne la liste des notes des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre.
    /// Les notes sont triées par nom de l'élève associé.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    ///
    /// - Parameters:
    ///   - searchString: caractères à rechercher dans les noms/prénom ou nombre à rechercher dans le n° de groupe
    /// - Returns: Liste des notes des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre
    func sortedMarksByEleveName(searchString: String = "") -> [MarkEntity] {
        let sortComparators = ExamEntity.nameSortOrder == .nomPrenom ?
            [
                SortDescriptor(\MarkEntity.eleve?.familyName, order: .forward),
                SortDescriptor(\MarkEntity.eleve?.givenName, order: .forward)
            ] :
            [
                SortDescriptor(\MarkEntity.eleve?.givenName, order: .forward),
                SortDescriptor(\MarkEntity.eleve?.familyName, order: .forward)
            ]

        return allMarks
            .filter { mark in
                if let eleve = mark.eleve {
                    return eleve.satisfiesTo(searchString: searchString)
                } else {
                    return false
                }
            }
            .sorted(using: sortComparators)
    }
}

// MARK: - Extension Debug

public extension ExamEntity {
    override var description: String {
        """

        EVALUATION: \(viewSujet)
           ID          : \(id)
           Date        : \(dateExecuted.stringShortDate)
           Noté sur    : \(maxMark)
           Coefficient : \(coef.formatted(.number.precision(.fractionLength(2))))
           Nombre de notes : \(nbOfMarks)
           Notes: \(String(describing: sortedMarksByEleveName()).withPrefixedSplittedLines("     "))
        """
    }
}
