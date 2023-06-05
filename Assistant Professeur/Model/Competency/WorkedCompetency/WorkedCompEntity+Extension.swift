//
//  WorkedCompEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import CoreData
import Foundation

extension WorkedCompEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static var defaultImageName: String {
        "brain.head.profile"
    }

    /// Wrapper of `number`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewNumber: Int {
        get {
            Int(self.number)
        }
        set {
            self.number = Int16(newValue)
            try? Self.saveIfContextHasChanged()
        }
    }

    @objc
    var viewAcronym: String {
        self.chapter?.viewAcronym ?? "??"
    }

    /// Wrapper of `descrip`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDescription: String {
        get {
            self.descrip ?? ""
        }
        set {
            self.descrip = newValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Nombre de Compétences Disciplinaires associées
    var nbOfDisciplineCompetencies: Int {
        Int(disCompCount)
    }
}

// MARK: - Extension CoreData

extension WorkedCompEntity {
    // MARK: - Type Computed Properties

    static var byAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \WorkedCompEntity.viewAcronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Acronym
    static var requestAllSortedByAcronym: NSFetchRequest<WorkedCompEntity> {
        let request = WorkedCompEntity.fetchRequest()
        request.sortDescriptors = Self.byAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Liste des Compétences Disciplinaires non triées
    var allDisciplineCompetencies: [DisciplineCompEntity] {
        if let disciplineCompetencies {
            return (disciplineCompetencies.allObjects as! [DisciplineCompEntity])
        } else {
            return []
        }
    }

    /// Liste des Compétences Disciplinaires triées par numéro
    var disciplineCompSortedByNumber: [DisciplineCompEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \DisciplineCompEntity.number,
                    order: .forward
                )
            ]
        return allDisciplineCompetencies.sorted(using: sortComparators)
    }

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    /// Retourne true si un object équivalent existe déjà dans le context.
    ///
    /// Si `objectID` != `nil` alors on retourne true seulement
    /// si l'objet existant possède le même identifiant.
    static func exists(
        acronym: String,
        objectID: NSManagedObjectID? = nil
    ) -> Bool {
        all().contains {
            $0.viewAcronym == acronym &&
                (objectID == nil || $0.objectID != objectID)
        }
    }

    // MARK: - Type Methods

    static func allSortedbyAcronym() -> [WorkedCompEntity] {
        do {
            return try WorkedCompEntity
                .context
                .fetch(WorkedCompEntity.requestAllSortedByAcronym)
        } catch {
            return []
        }
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Saves the context
    @discardableResult
    static func create(
        number: Int,
        description: String
    ) -> WorkedCompEntity {
        let comp = WorkedCompEntity.create()

        comp.number = Int16(number)
        comp.descrip = description

        try? Self.saveIfContextHasChanged()
        return comp
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList
    ) {
        all().forEach { comp in
            if comp.descrip == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: comp.description,
                    attribute: "descrip",
                    id: comp.id
                ))
            }
        }
    }
}

// MARK: - Extension Debug

public extension WorkedCompEntity {
    override var description: String {
        """

        COMPÉTENCES DU SOCLE:
           ID          : \(String(describing: id))
           Numéro      : \(viewNumber)
           Description : \(viewDescription)
           Compétences : \(String(describing: disciplineCompetencies).withPrefixedSplittedLines("     "))
        """
    }
}
