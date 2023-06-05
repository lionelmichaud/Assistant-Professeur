//
//  WorkedCompetencyChapterEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import CoreData
import Foundation

extension WorkedCompChapterEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static var defaultImageName: String {
        "brain.head.profile"
    }

    /// Wrapper of `cycle`
    /// - Important: *Saves the context to the store after modification is done*
    var viewCycleEnum: Cycle {
        get {
            if let cycle {
                return Cycle(rawValue: cycle) ?? .cycle4
            } else {
                return .cycle4
            }
        }
        set {
            self.cycle = newValue.rawValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `cycle`
    /// - Important: *Does NOT save the context to the store after modification is done*
    var cycleEnum: Cycle {
        get {
            if let cycle {
                return Cycle(rawValue: cycle) ?? .cycle4
            } else {
                return .cycle4
            }
        }
        set {
            self.cycle = newValue.rawValue
        }
    }

    @objc
    var cycleString: String {
        viewCycleEnum.displayString
    }

    /// Modifie l'attribut `cycle`
    func setCycle(_ newCycle: Cycle) {
        self.cycle = newCycle.rawValue
    }

    /// Wrapper of `acronym`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAcronym: String {
        get {
            self.acronym ?? ""
        }
        set {
            self.acronym = newValue
            try? Self.saveIfContextHasChanged()
        }
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

    /// Nombre de Compétences Travaillées associées
    var nbOfWorkedCompetencies: Int {
        Int(compCount)
    }
}

// MARK: - Extension CoreData

extension WorkedCompChapterEntity {
    // MARK: - Type Computed Properties

    static var byCycleAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \WorkedCompChapterEntity.cycle,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \WorkedCompChapterEntity.acronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Cycle
    ///   2. Titre
    static var requestAllSortedbyCycleTitle: NSFetchRequest<WorkedCompChapterEntity> {
        let request = WorkedCompChapterEntity.fetchRequest()
        request.sortDescriptors = Self.byCycleAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Liste des Compétences Travaillées non triées
    var allWorkedCompetencies: [WorkedCompEntity] {
        if let competencies {
            return (competencies.allObjects as! [WorkedCompEntity])
        } else {
            return []
        }
    }

    /// Liste des Compétences Travaillées triées par numéro
    var sequencesSortedByNumber: [WorkedCompEntity] {
        let sortComparators =
            [
                SortDescriptor(\WorkedCompEntity.number, order: .forward)
            ]
        return allWorkedCompetencies.sorted(using: sortComparators)
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
        cycle: Cycle,
        acronym: String,
        objectID: NSManagedObjectID? = nil
    ) -> Bool {
        all().contains {
            $0.viewCycleEnum == cycle &&
            $0.viewAcronym == acronym &&
            (objectID == nil || $0.objectID != objectID)
        }
    }

    // MARK: - Type Methods

    static func allSortedbyCycleTitle() -> [WorkedCompChapterEntity] {
        do {
            return try WorkedCompChapterEntity
                .context
                .fetch(WorkedCompChapterEntity.requestAllSortedbyCycleTitle)
        } catch {
            return []
        }
    }
    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Saves the context
    @discardableResult
    static func create(
        cycle: Cycle,
        acronym: String,
        description: String
    ) -> WorkedCompChapterEntity {
        let chapter = WorkedCompChapterEntity.create()

        chapter.cycle = cycle.rawValue
        chapter.acronym = acronym
        chapter.descrip = description

        try? Self.saveIfContextHasChanged()
        return chapter
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList
    ) {
        all().forEach { chapter in
            if chapter.cycle == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: chapter.description,
                    attribute: "cycle",
                    id: chapter.id
                ))
            }
            if chapter.acronym == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: chapter.description,
                    attribute: "acronym",
                    id: chapter.id
                ))
            }
            if chapter.descrip == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: chapter.description,
                    attribute: "descrip",
                    id: chapter.id
                ))
            }
        }
    }
}

// MARK: - Extension Debug

public extension WorkedCompChapterEntity {
    override var description: String {
        """

        ÉLÉMENT DE COMPÉTENCES DU SOCLE:
           ID          : \(String(describing: id))
           Cycle       : \(cycleString)
           Code        : \(viewAcronym)
           Description : \(viewDescription)
           Compétences : \(String(describing: competencies).withPrefixedSplittedLines("     "))
        """
    }
}
