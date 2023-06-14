//
//  DCompEntity+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import Foundation

extension DCompEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter
    /// une section de compétences disciplinaires
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
        (self.section?.viewAcronym ?? "??") + "." +
            String(self.viewNumber)
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
    var nbOfKnowledges: Int {
        Int(knowledgesCount)
    }
}

// MARK: - Extension CoreData

extension DCompEntity {
    // MARK: - Type Computed Properties

    static var byAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \DCompEntity.viewAcronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les sections de compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Acronym
    static var requestAllSortedByAcronym: NSFetchRequest<DCompEntity> {
        let request = DCompEntity.fetchRequest()
        request.sortDescriptors = Self.byAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Liste des Connaissances Disciplinaires de la compétence, non triées
    var allKnowledges: [DKnowledgeEntity] {
        if let knowledges {
            return (knowledges.allObjects as! [DKnowledgeEntity])
        } else {
            return []
        }
    }

    /// Liste des Connaissances Disciplinaires de la compétence, triées par numéro
    var allKnowledgesSortedByNumber: [DKnowledgeEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \DKnowledgeEntity.number,
                    order: .forward
                )
            ]
        return allKnowledges.sorted(using: sortComparators)
    }

    // MARK: - Type Methods

    static func allSortedByAcronym() -> [DCompEntity] {
        do {
            return try DCompEntity
                .context
                .fetch(DCompEntity.requestAllSortedByAcronym)
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
        inSection section: DSectionEntity
    ) -> DCompEntity {
        let competency = DCompEntity.create()

        competency.number = Int16(number)
        competency.descrip = description

        competency.section = section

        try? Self.saveIfContextHasChanged()
        return competency
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { competency in
            if competency.descrip == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: competency.description,
                    attribute: "descrip",
                    id: competency.id
                ))
            }
            if competency.section == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try competency.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: competency.description,
                            id: competency.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: competency.description,
                        id: competency.id
                    ))
                }
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }
    /// Recherche si la **Connaissance** existe déjà dans cette **Compétence**.
    ///
    /// Si `thisObjectID` != `nil` alors on retourne true seulement
    /// si un objet existant possède un identifiant différent de `thisObjectID`.
    func exists(
        number: Int,
        thisObjectID: NSManagedObjectID? = nil
    ) -> Bool {
        allKnowledges.contains {
            $0.viewNumber == number &&
            (thisObjectID == nil || $0.objectID != thisObjectID)
        }
    }
}

// MARK: - Extension Debug

public extension DCompEntity {
    override var description: String {
        """

        COMPÉTENCES DISCIPLINAIRE:
           ID          : \(String(describing: id))
           Section     : \(String(describing: section?.viewAcronym))
           Numéro      : \(viewNumber)
           Description : \(viewDescription)
        """
        //           Compétences disciplinaires : \(String(describing: disciplineCompetencies).withPrefixedSplittedLines("     "))
    }
}
