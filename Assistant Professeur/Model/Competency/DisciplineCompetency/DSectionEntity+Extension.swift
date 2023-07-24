//
//  DSectionEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import CoreData
import Foundation

extension DSectionEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter
    /// une section de compétences disciplinaires
    static var defaultImageName: String {
        "text.book.closed.fill"
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
        (self.theme?.viewAcronym ?? "??") + "." + String(self.viewNumber)
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

    /// Wrapper of `progressivity`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewProgressivity: String {
        get {
            self.progressivity ?? ""
        }
        set {
            self.progressivity = newValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Nombre de Compétences Disciplinaires associées
    var nbOfCompetencies: Int {
        Int(compCount)
    }
}

// MARK: - Extension CoreData

extension DSectionEntity {
    // MARK: - Type Computed Properties

    static var byAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \DSectionEntity.viewAcronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les sections de compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Acronym
    static var requestAllSortedByAcronym: NSFetchRequest<DSectionEntity> {
        let request = DSectionEntity.fetchRequest()
        request.sortDescriptors = Self.byAcronymNSSortDescriptor
        return request
    }

    // MARK: - Type Methods

    static func allSortedbyAcronym() -> [DSectionEntity] {
        do {
            return try DSectionEntity
                .context
                .fetch(DSectionEntity.requestAllSortedByAcronym)
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
        progressivity: String,
        inTheme theme: DThemeEntity
    ) -> DSectionEntity {
        let section = DSectionEntity.create()

        section.number = Int16(number)
        section.descrip = description
        section.progressivity = progressivity

        section.theme = theme

        try? Self.saveIfContextHasChanged()
        return section
    }
    // MARK: - Section de Compétences

    /// Liste des compétences Disciplinaires de la section, non triées
    var allCompetencies: [DCompEntity] {
        if let competencies {
            return (competencies.allObjects as! [DCompEntity])
        } else {
            return []
        }
    }

    /// Liste des Compétences Disciplinaires de la section, triées par numéro
    var allCompetenciesSortedByNumber: [DCompEntity] {
        let sortComparators =
        [
            SortDescriptor(
                \DCompEntity.number,
                 order: .forward
            )
        ]
        return allCompetencies.sorted(using: sortComparators)
    }


    /// Recherche si la **Competence** existe déjà dans cette **Section**.
    ///
    /// Si `thisObjectID` != `nil` alors on retourne true seulement
    /// si un objet existant possède un identifiant différent de `thisObjectID`.
    func competencyExists(
        number: Int,
        thisObjectID: NSManagedObjectID? = nil
    ) -> Bool {
        allCompetencies.contains {
            $0.viewNumber == number &&
            (thisObjectID == nil || $0.objectID != thisObjectID)
        }
    }

    // MARK: - Contrôle de la BDD

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { section in
            if section.descrip == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: section.description,
                    attribute: "descrip",
                    id: section.id
                ))
            }
            if section.progressivity == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: section.description,
                    attribute: "progressivity",
                    id: section.id
                ))
            }
            if section.theme == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try section.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: section.description,
                            id: section.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: section.description,
                        id: section.id
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

public extension DSectionEntity {
    override var description: String {
        """

        SECTION DISCIPLINAIRE:
           ID            : \(String(describing: id))
           Thème         : \(String(describing: theme?.viewAcronym))
           Numéro        : \(viewNumber)
           Description   : \(viewDescription)
           Progressivité : \(viewProgressivity)
        """
        //           Compétences disciplinaires : \(String(describing: disciplineCompetencies).withPrefixedSplittedLines("     "))
    }
}
