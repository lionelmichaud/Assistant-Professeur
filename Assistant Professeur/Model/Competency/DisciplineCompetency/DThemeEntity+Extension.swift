//
//  DThemeEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 07/06/2023.
//

import CoreData
import Foundation

extension DThemeEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter
    /// un thème de compétences disciplinaires
    static var defaultImageName: String {
        "text.book.closed.fill"
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

    /// Wrapper of `discipline`
    /// - Important: *Saves the context to the store after modification is done*
    var viewDisciplineEnum: Discipline {
        get {
            if let discipline {
                return Discipline(rawValue: discipline) ?? .technologie
            } else {
                return .technologie
            }
        }
        set {
            self.discipline = newValue.rawValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `discipline`
    /// - Important: *Does NOT save the context to the store after modification is done*
    var disciplineEnum: Discipline {
        get {
            if let discipline {
                return Discipline(rawValue: discipline) ?? .technologie
            } else {
                return .technologie
            }
        }
        set {
            self.discipline = newValue.rawValue
        }
    }

    @objc
    var disciplineString: String {
        viewDisciplineEnum.displayString
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

    /// Nombre de Sections de Compétences disciplinaires
    var nbOfSections: Int {
        Int(sectionsCount)
    }
}

// MARK: - Extension CoreData

extension DThemeEntity {
    // MARK: - Type Computed Properties

    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Cycle
    ///   3. Titre du thème
    static var byDiscCycleAcronymNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \DThemeEntity.cycle,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \DThemeEntity.discipline,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \DThemeEntity.acronym,
                ascending: true
            )
        ]

    /// Requête pour toutes les **Thèmes** de compétences disciplinaires triées.
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Cycle
    ///   3. Titre du thème
    static var requestAllSortedByDiscCycleAcronym: NSFetchRequest<DThemeEntity> {
        let request = DThemeEntity.fetchRequest()
        request.sortDescriptors = Self.byDiscCycleAcronymNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Liste des **Sections** de compétences disciplinaires non triées
    var allSections: [DSectionEntity] {
        if let sections {
            return (sections.allObjects as! [DSectionEntity])
        } else {
            return []
        }
    }

    /// Liste des **Sections** de compétences disciplinaires triées par numéro
    var allSectionsSortedByNumber: [DSectionEntity] {
        let sortComparators =
            [
                SortDescriptor(\DSectionEntity.number, order: .forward)
            ]
        return allSections.sorted(using: sortComparators)
    }

    // MARK: - Type Methods

    /// Nombre de thèmes dans cette `discipline`
    static func nbOfThemes(for discipline: Discipline) -> Int {
        all().filter {
            $0.disciplineEnum == discipline
        }.count
    }

    /// Retourne true si un object équivalent existe déjà dans le context.
    ///
    /// Si `thisObjectID` != `nil` alors on retourne true seulement
    /// si un objet existant possède un identifiant différent de `thisObjectID`.
    static func exists(
        cycle: Cycle,
        discipline: Discipline,
        acronym: String,
        thisObjectID: NSManagedObjectID? = nil
    ) -> Bool {
        all().contains {
            $0.viewCycleEnum == cycle &&
                $0.viewDisciplineEnum == discipline &&
                $0.viewAcronym == acronym &&
                (thisObjectID == nil || $0.objectID != thisObjectID)
        }
    }

    /// Liste de tous les **Thèmes** de compétences disciplinaires triées.
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Cycle
    ///   3. Titre du thème
    static func allSortedbyDiscCycleTitle() -> [DThemeEntity] {
        do {
            return try DThemeEntity
                .context
                .fetch(DThemeEntity.requestAllSortedByDiscCycleAcronym)
        } catch {
            return []
        }
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Saves the context
    @discardableResult
    static func create(
        cycle: Cycle,
        discipline: Discipline,
        acronym: String,
        description: String,
        progressivity: String
    ) -> DThemeEntity {
        let theme = DThemeEntity.create()

        theme.cycle = cycle.rawValue
        theme.discipline = discipline.rawValue
        theme.acronym = acronym
        theme.descrip = description
        theme.progressivity = progressivity

        try? Self.saveIfContextHasChanged()
        return theme
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList
    ) {
        all().forEach { theme in
            if theme.cycle == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: theme.description,
                    attribute: "cycle",
                    id: theme.id
                ))
            }
            if theme.discipline == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: theme.description,
                    attribute: "discipline",
                    id: theme.id
                ))
            }
            if theme.acronym == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: theme.description,
                    attribute: "acronym",
                    id: theme.id
                ))
            }
            if theme.descrip == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: theme.description,
                    attribute: "descrip",
                    id: theme.id
                ))
            }
            if theme.progressivity == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: theme.description,
                    attribute: "progressivity",
                    id: theme.id
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

    /// Recherche si la **Section** existe déjà dans ce **Theme**.
    ///
    /// Si `thisObjectID` != `nil` alors on retourne true seulement
    /// si un objet existant possède un identifiant différent de `thisObjectID`.
    func exists(
        number: Int,
        thisObjectID: NSManagedObjectID? = nil
    ) -> Bool {
        allSections.contains {
            $0.viewNumber == number &&
                (thisObjectID == nil || $0.objectID != thisObjectID)
        }
    }
}

// MARK: - Extension Debug

public extension DThemeEntity {
    override var description: String {
        """

        THEME DISCIPLINAIRE:
           ID            : \(String(describing: id))
           Discipline    : \(disciplineString)
           Cycle         : \(cycleString)
           Code          : \(viewAcronym)
           Description   : \(viewDescription)
           Progressivité : \(viewProgressivity)
           Sections      : \(String(describing: sections).withPrefixedSplittedLines("     "))
        """
    }
}
