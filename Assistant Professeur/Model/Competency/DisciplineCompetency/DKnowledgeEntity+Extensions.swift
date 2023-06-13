//
//  DKnowledgeEntity+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 11/06/2023.
//

import CoreData
import Foundation

extension DKnowledgeEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter
    /// une section de compétences disciplinaires
    static var defaultImageName: String {
        "text.bubble"
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
        (self.competency?.viewAcronym ?? "??") + "." +
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
}

// MARK: - Extension CoreData

extension DKnowledgeEntity {
    // MARK: - Type Computed Properties

    static var byAcronymNSSortDescriptor: [NSSortDescriptor] =
    [
        NSSortDescriptor(
            keyPath: \DKnowledgeEntity.viewAcronym,
            ascending: true
        )
    ]

    /// Requête pour toutes les sections de compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Acronym
    static var requestAllSortedByAcronym: NSFetchRequest<DKnowledgeEntity> {
        let request = DKnowledgeEntity.fetchRequest()
        request.sortDescriptors = Self.byAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    // MARK: - Type Methods

    static func allSortedByAcronym() -> [DKnowledgeEntity] {
        do {
            return try DKnowledgeEntity
                .context
                .fetch(DKnowledgeEntity.requestAllSortedByAcronym)
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
        inCompetency competency: DCompEntity
    ) -> DKnowledgeEntity {
        let knowledge = DKnowledgeEntity.create()

        knowledge.number = Int16(number)
        knowledge.descrip = description

        knowledge.competency = competency

        try? Self.saveIfContextHasChanged()
        return knowledge
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { knowledge in
            if knowledge.descrip == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: knowledge.description,
                    attribute: "descrip",
                    id: knowledge.id
                ))
            }
            if knowledge.competency == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try knowledge.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: knowledge.description,
                            id: knowledge.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: knowledge.description,
                        id: knowledge.id
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
}

// MARK: - Extension Debug

public extension DKnowledgeEntity {
    override var description: String {
        """

        CONNAISSANCES DISCIPLINAIRE:
           ID          : \(String(describing: id))
           Compétence  : \(String(describing: competency?.viewAcronym))
           Numéro      : \(viewNumber)
           Description : \(viewDescription)
        """
        //           Compétences disciplinaires : \(String(describing: disciplineCompetencies).withPrefixedSplittedLines("     "))
    }
}
