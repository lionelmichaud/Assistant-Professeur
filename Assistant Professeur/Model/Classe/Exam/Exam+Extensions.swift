//
//  Exam+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2023.
//

import Foundation
import CoreData

/// Un établissement scolaire
extension ExamEntity {

    // MARK: - Computed properties

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
            Int(self.maxMark)
        }
        set {
            self.maxMark = Int16(newValue)
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Nombre de notes de cette évaluation.
    /// En principe, autant que d'élèves dans la classe associée.
    var nbOfMarks: Int {
        Int(marksCount)
    }
}

// MARK: - Extension Core Data

extension ExamEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    @Preference(\.nameSortOrder)
    static private var nameSortOrder

    // MARK: - Computed Properties

    /// Liste des notes de l'évaluation non triées
    var allMarks: [MarkEntity] {
        if let marks {
            return (marks.allObjects as! [MarkEntity])
        } else {
            return [ ]
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

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
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

extension ExamEntity {
    public override var description: String {
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

