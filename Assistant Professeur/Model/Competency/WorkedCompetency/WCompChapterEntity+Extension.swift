//
//  WorkedCompetencyChapterEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import CoreData
import Foundation

extension WCompChapterEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static let defaultImageName: String = "text.book.closed.fill"

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

    /// Nombre de **Compétences** Travaillées dans ce **Chapitre**
    var nbOfWorkedCompetencies: Int {
        Int(compCount)
    }
}

// MARK: - Extension CoreData

extension WCompChapterEntity {
    // MARK: - Type Computed Properties

    /// Ordre de tri:
    ///   1. Cycle
    ///   2. Acronyme
    static var byCycleAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \WCompChapterEntity.cycle,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \WCompChapterEntity.acronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les **Chapitres** de compétences triées.
    ///
    /// Ordre de tri:
    ///   1. Cycle
    ///   2. Acronyme
    static var requestAllSortedByCycleAcronymTitle: NSFetchRequest<WCompChapterEntity> {
        let request = WCompChapterEntity.fetchRequest()
        request.sortDescriptors = Self.byCycleAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Liste des **Compétences** Travaillées du **Chapitre**, non triées
    var allWorkedCompetencies: [WCompEntity] {
        if let competencies {
            return (competencies.allObjects as! [WCompEntity])
        } else {
            return []
        }
    }

    /// Liste des **Compétences** Travaillées du **Chapitre** triées par numéro
    var allWorkedCompetenciesSortedByNumber: [WCompEntity] {
        let sortComparators =
            [
                SortDescriptor(\WCompEntity.number, order: .forward)
            ]
        return allWorkedCompetencies.sorted(using: sortComparators)
    }

    // MARK: - Type Methods

    /// Retourne true si un object équivalent existe déjà dans le context.
    ///
    /// Si `thisObjectID` != `nil` alors on retourne true seulement
    /// si un objet existant possède un identifiant différent de `thisObjectID`.
    static func exists(
        cycle: Cycle,
        acronym: String,
        thisObjectID: NSManagedObjectID? = nil
    ) -> Bool {
        all().contains {
            $0.viewCycleEnum == cycle &&
                $0.viewAcronym == acronym &&
                (thisObjectID == nil || $0.objectID != thisObjectID)
        }
    }

    /// Liste de tous les **Chapitres** de compétences travaillées triées.
    ///
    /// Ordre de tri:
    ///   1. Cycle
    ///   2. Acronyme
    static func allSortedbyCycleAcronymTitle() -> [WCompChapterEntity] {
        do {
            return try WCompChapterEntity
                .context
                .fetch(WCompChapterEntity.requestAllSortedByCycleAcronymTitle)
        } catch {
            return []
        }
    }

    /// Liste de tous les **Chapitres** de compétences travaillées triées satisfaisant au critères:
    /// `cycle`
    ///
    /// Ordre de tri:
    ///   1. Cycle
    ///   2. Acronyme
   static func sortedbyCycleAcronymTitle(
        forCycle cycle: Cycle 
    ) -> [WCompChapterEntity] {
        allSortedbyCycleAcronymTitle().filter { chapter in
            chapter.viewCycleEnum == cycle
        }
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Saves the context
    @discardableResult
    static func create(
        cycle: Cycle,
        acronym: String,
        description: String
    ) -> WCompChapterEntity {
        let chapter = WCompChapterEntity.create()

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

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    /// Recherche si la **Compétence** existe déjà dans ce **Chapitre**.
    ///
    /// Si `thisObjectID` != `nil` alors on retourne true seulement
    /// si un objet existant possède un identifiant différent de `thisObjectID`.
    func exists(
        number: Int,
        thisObjectID: NSManagedObjectID? = nil
    ) -> Bool {
        (self.competencies?.allObjects as! [WCompEntity])
            .contains {
                $0.viewNumber == number &&
                    (thisObjectID == nil || $0.objectID != thisObjectID)
            }
    }
}

// MARK: - Extension Debug

public extension WCompChapterEntity {
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
