//
//  Program+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/01/2023.
//

import CoreData
import Foundation

/// Un programme scolaire pour une dscipline et un niveau donnés
extension ProgramEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static var defaultImageName: String {
        "books.vertical"
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

    /// Wrapper of `level`
    /// - Important: *Saves the context to the store after modification is done*
    var viewLevelEnum: LevelClasse {
        get {
            if let level {
                return LevelClasse(rawValue: level) ?? .n6ieme
            } else {
                return .n6ieme
            }
        }
        set {
            self.level = newValue.rawValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `level`
    /// - Important: *Does NOT save the context to the store after modification is done*
    var levelEnum: LevelClasse {
        get {
            if let level {
                return LevelClasse(rawValue: level) ?? .n6ieme
            } else {
                return .n6ieme
            }
        }
        set {
            self.level = newValue.rawValue
        }
    }

    @objc
    var levelString: String {
        viewLevelEnum.displayString
    }

    /// Wrapper of `segpa`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSegpa: Bool {
        get {
            self.segpa
        }
        set {
            self.segpa = newValue
            try? Self.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `annotation`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAnnotation: String {
        get {
            self.annotation ?? ""
        }
        set {
            self.annotation = newValue
            try? Self.saveIfContextHasChanged()
        }
    }

    // MARK: - Methods

    /// Modifie l'attribut `discipline`
    func setDiscipline(_ newDiscipline: Discipline) {
        self.discipline = newDiscipline.rawValue
    }

    /// Modifie l'attribut `level`
    func setLevel(_ newLevel: LevelSchool) {
        self.level = newLevel.rawValue
    }

    /// Nombre de Séquences dans le Programme de l'année
    var nbOfSequences: Int {
        Int(sequencesCount)
    }
}

// MARK: - Extension Core Data

extension ProgramEntity {
    // MARK: - Type Computed Properties

    static var byDisciplineLevelSegpaNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \ProgramEntity.discipline,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \ProgramEntity.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \ProgramEntity.segpa,
                ascending: true
            )
        ]

    /// Requête pour tous les programmes triés.
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Niveau de la Classe
    ///   3. SGPA ou non
    static var requestAllSortedbyDisciplineLevelSegpa: NSFetchRequest<ProgramEntity> {
        let request = ProgramEntity.fetchRequest()
        request.sortDescriptors = Self.byDisciplineLevelSegpaNSSortDescriptor
        return request
    }

    // MARK: - Computed properties

    /// Somme des durées des séquences
    /// sans marge à la fin de chaque séquence
    var durationWithoutMargin: Double {
        allSequences.reduce(0) { $0 + $1.durationWithoutMargin }
    }

    /// Somme des durées des séquences
    /// + une marge d'une séance à la fin de chaque séquence
    var durationWithMargin: Double {
        allSequences.reduce(0) { $0 + $1.durationWithMargin }
    }

    /// Liste des séquences du programme non triées
    var allSequences: [SequenceEntity] {
        if let sequences {
            return (sequences.allObjects as! [SequenceEntity])
        } else {
            return []
        }
    }

    /// Liste des séquences du programme triées par numéro de séquence
    var sequencesSortedByNumber: [SequenceEntity] {
        let sortComparators =
            [
                SortDescriptor(\SequenceEntity.number, order: .forward)
            ]
        return allSequences.sorted(using: sortComparators)
    }

    // MARK: - Méthodes

    /// Liste des séquences du programme filtrées et triées par numéro de séquence
    func filteredSequencesSortedByNumber(
        searchString: String
    ) -> [SequenceEntity] {
        guard searchString.isNotEmpty else {
            return sequencesSortedByNumber
        }

        let sortComparators =
            [
                SortDescriptor(\SequenceEntity.number, order: .forward)
            ]
        return allSequences
            .filter { seq in
                let string = searchString.lowercased()
                return seq.name!.lowercased().contains(string)
            }
            .sorted(using: sortComparators)
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
        dscipline: Discipline,
        classeLevel: LevelClasse,
        classeIsSegpa: Bool,
        objectID: NSManagedObjectID? = nil
    ) -> Bool {
        all().contains {
            $0.viewDisciplineEnum == dscipline &&
            $0.viewLevelEnum == classeLevel &&
            $0.segpa == classeIsSegpa &&
            (objectID == nil || $0.objectID != objectID)
        }
    }

    // MARK: - Type Methods

    static func allSortedbyDisciplineLevelSegpa() -> [ProgramEntity] {
        do {
            return try ProgramEntity
                .context
                .fetch(ProgramEntity.requestAllSortedbyDisciplineLevelSegpa)
        } catch {
            return []
        }
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Saves the context
    @discardableResult
    static func create(
        discipline: Discipline,
        level: LevelClasse,
        segpa: Bool,
        annotation: String = "",
        url: URL? = nil
    ) -> ProgramEntity {
        let program = ProgramEntity.create()

        program.discipline = discipline.rawValue
        program.level = level.rawValue
        program.segpa = segpa
        program.annotation = annotation
        program.url = url

        try? Self.saveIfContextHasChanged()
        return program
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList
    ) {
        all().forEach { program in
            if program.discipline == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: program.description,
                    attribute: "discipline",
                    id: program.id
                ))
            }
            if program.level == nil {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: program.description,
                    attribute: "level",
                    id: program.id
                ))
            }
        }
    }
}

// MARK: - Extension Debug

public extension ProgramEntity {
    override var description: String {
        """

        PROGRAMME:
           ID           : \(String(describing: id))
           Discipline   : \(disciplineString)
           Niveau       : \(levelString)
           SEGPA        : \(segpa.frenchString)
           Annotation   : \(String(describing: self.annotation))
           URL          : \(String(describing: url))
           Nb séquences : \(sequencesCount)
           Séquences : \(String(describing: sequencesSortedByNumber).withPrefixedSplittedLines("     "))
        """
    }
}
