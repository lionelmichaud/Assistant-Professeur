//
//  WCompEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import CoreData
import Foundation

extension WCompEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter une compétence travaillée
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
        (self.chapter?.viewAcronym ?? "??") + "." + String(self.viewNumber)
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

extension WCompEntity {
    // MARK: - Type Computed Properties

    static var byAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \WCompEntity.viewAcronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Acronym
    static var requestAllSortedByAcronym: NSFetchRequest<WCompEntity> {
        let request = WCompEntity.fetchRequest()
        request.sortDescriptors = Self.byAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Liste des Compétences Disciplinaires non triées
    var allDisciplineCompetencies: [DCompEntity] {
        if let disciplineCompetencies {
            return (disciplineCompetencies.allObjects as! [DCompEntity])
        } else {
            return []
        }
    }

    /// Liste des Compétences Disciplinaires triées par numéro
    var disciplineCompSortedByNumber: [DCompEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \DCompEntity.number,
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

    // MARK: - Type Methods

    static func allSortedbyAcronym() -> [WCompEntity] {
        do {
            return try WCompEntity
                .context
                .fetch(WCompEntity.requestAllSortedByAcronym)
        } catch {
            return []
        }
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Saves the context
    @discardableResult
    static func create(
        number: Int,
        description: String,
        inChapter chapter: WCompChapterEntity
    ) -> WCompEntity {
        let comp = WCompEntity.create()

        comp.number = Int16(number)
        comp.descrip = description

        comp.chapter = chapter

        try? Self.saveIfContextHasChanged()
        return comp
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
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
            if comp.chapter == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try comp.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: comp.description,
                            id: comp.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: comp.description,
                        id: comp.id
                    ))
                }
            }
        }
    }
}

// MARK: - Extension Debug

public extension WCompEntity {
    override var description: String {
        """

        COMPÉTENCES DU SOCLE:
           ID          : \(String(describing: id))
           Chapitre    : \(String(describing: chapter?.viewAcronym))
           Numéro      : \(viewNumber)
           Description : \(viewDescription)
        """
        //           Compétences disciplinaires : \(String(describing: disciplineCompetencies).withPrefixedSplittedLines("     "))
    }
}
