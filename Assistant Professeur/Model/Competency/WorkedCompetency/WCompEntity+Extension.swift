//
//  WCompEntity+Extension.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import Collections
import CoreData
import Foundation

/// Dictionnaire de compétences disciplinaires ordonné par discipline. [ Discipline : [Compétences disciplinaires] ].
typealias DicoDCompsPerLevel = OrderedDictionary<Discipline, [DCompEntity]>
extension DicoDCompsPerLevel {
    var cardinal: Int {
        self.values.reduce(into: 0) { partialResult, sequences in
            partialResult += sequences.count
        }
    }
}

/// Dictionnaire de séquence ordonné par niveau de classe. [ Niveau de classe : [Sequences] ].
typealias DicoSequencesPerLevel = OrderedDictionary<LevelClasse, [SequenceEntity]>
extension DicoSequencesPerLevel {
    var cardinal: Int {
        self.values.reduce(into: 0) { partialResult, sequences in
            partialResult += sequences.count
        }
    }
}

/// Dictionnaire de séquence ordonné par discipline et niveau. [Discipline : [ Niveau de classe : [Sequences] ] ].
typealias DicoSequencesPerDisciplineLevel = OrderedDictionary<Discipline, DicoSequencesPerLevel>
extension DicoSequencesPerDisciplineLevel {
    var cardinal: Int {
        self.values.reduce(into: 0) { partialResult, dico in
            partialResult += dico.cardinal
        }
    }
}

/// Compétence travaillée du Socle de compétence
extension WCompEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter une compétence travaillée
    static let defaultImageName: String = "gearshape.2"

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
    @objc
    var nbOfDisciplineCompetencies: Int {
        Int(disCompCount)
    }

    /// Wrapper of `masteryDefinition`
    ///
    /// - Important: *Saves the context to the store after modification is done*
    var viewMasteryDefinitions: MasteryLevelDictionary {
        get {
            getMasteryDefinitions(fromString: masteryDefinitions)
        }
        set {
            setMasteryDefinitions(newValue)
            try? WCompEntity.saveIfContextHasChanged()
        }
    }

    /// Décode l'attribut `masteryDefinition` à partir d'une String `fromString`au format JSON.
    private func getMasteryDefinitions(fromString masteryDefString: String?) -> MasteryLevelDictionary {
        if let masteryDefString {
            let data = Data(masteryDefString.utf8)
            return (try? JSONDecoder().decode(MasteryLevelDictionary.self, from: data)) ?? [:]
        } else {
            return [:]
        }
    }

    /// Modifie l'attribut `masteryDefinition` en encodant les étapes au format JSON.
    /// - Important: *Does NOT save the context to the store after modification is done*
    private func setMasteryDefinitions(_ masteryDefinitions: MasteryLevelDictionary) {
        guard let data = try? JSONEncoder().encode(masteryDefinitions),
              let string = String(data: data, encoding: .utf8) else {
            self.masteryDefinitions = ""
            return
        }
        self.masteryDefinitions = string
    }
}

// MARK: - Extension CoreData

extension WCompEntity {
    // MARK: - Compétences Disciplinaires associées

    /// Liste des Compétences Disciplinaires non triées
    var allDisciplineCompetencies: [DCompEntity] {
        if let disciplineCompetencies {
            return (disciplineCompetencies.allObjects as! [DCompEntity])
        } else {
            return []
        }
    }

    /// Liste des Compétences Disciplinaires triées.
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Acronym
    var allDisciplineCompSortedByDisciplineAcronym: [DCompEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \DCompEntity.section?.theme?.disciplineString,
                     order: .forward
                ),
                SortDescriptor(
                    \DCompEntity.viewAcronym,
                    order: .forward
                )
            ]
        return allDisciplineCompetencies.sorted(using: sortComparators)
    }

    /// Retourne les Compétences Disciplinaires associées à cette compétence sous forme d'un
    /// dictionnaire ordonné par discipline : [ Discipline : [Compétences disciplinaires] ].
    ///
    /// - Note: Les Compétences Disciplinaires retournées sont toutes disciplines confondues.
    ///
    /// Ordre de classement dans les dictionnaires:
    ///   1. Discipline
    ///   2. Acronym
    func disciplineCompSortedByDisciplineAcronym() -> DicoDCompsPerLevel {
        // toutes les séquences
        let allDComps = allDisciplineCompSortedByDisciplineAcronym

        // Creates a new dictionary whose keys are the groupings returned by the given closure
        // and whose values are arrays of the elements that returned each key
        let dicoOfDcompsArraysByDiscipline = OrderedDictionary(
            grouping: allDComps,
            by: { $0.section!.theme!.disciplineEnum }
        )

        return dicoOfDcompsArraysByDiscipline
    }

    // MARK: - Séquences pédagogiques associées

    /// Retourne toutes les séquences associées à cette compétence et triées.
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Niveau de classe
    ///   3. Numéro de séquence
    var allSequencesSortedByDisciplineLevelNumber: [SequenceEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \SequenceEntity.program?.disciplineString,
                    order: .forward
                ),
                SortDescriptor(
                    \SequenceEntity.program?.levelSortOrder,
                    order: .forward
                ),
                SortDescriptor(
                    \SequenceEntity.viewNumber,
                    order: .forward
                )
            ]
        let allSequences = allDisciplineCompetencies.flatMap { dComp in
            dComp.allActivities.compactMap { activity in
                activity.sequence
            }
        }
        return Array(Set(allSequences)) // élimine les doublons
            .sorted(using: sortComparators)
    }

    /// Retourne les séquences associées à cette compétence
    /// de niveau `level` et triées.
    ///
    /// - Note: Les séquences retournées sont toutes disciplines confondues.
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Numéro de séquence
    func sequencesSortedByDisciplineNumber(
        level: LevelClasse
    ) -> [SequenceEntity] {
        allSequencesSortedByDisciplineLevelNumber
            .filter { sequence in
                sequence.program?.levelEnum == level
            }
    }

    /// Retourne les séquences associées à cette compétence
    /// pour la `discipline` et triées.
    ///
    /// - Note: Les séquences retournées sont tous niveaux de classe confondus.
    ///
    /// Ordre de tri:
    ///   1. Niveau de classe
    ///   2. Numéro de séquence
    func sequencesSortedByLevelNumber(
        discipline: Discipline
    ) -> [SequenceEntity] {
        allSequencesSortedByDisciplineLevelNumber
            .filter { sequence in
                sequence.program?.disciplineEnum == discipline
            }
    }

    /// Retourne les séquences associées à cette compétence sous forme d'un
    /// tableau de tableau [Dsicipline [Niveau de classe ] ].
    ///
    /// - Note: Les séquences retournées sont toutes disciplines et tous niveaux de classe confondus.
    ///
    /// Ordre de classement dans le tableau:
    ///   1. Discipline
    ///   2. Niveau de classe
    ///   3. Numéro de séquence
    func sequencesArraysPerDiscipleSortedByDisciplineNumber() -> [[SequenceEntity]] {
        let allSequences = allDisciplineCompetencies.flatMap { dComp in
            dComp.allActivities.compactMap { activity in
                activity.sequence
            }
        }
        let disciplines =
            Array(Set(allSequences.compactMap { $0.program?.disciplineEnum }))
        var table = [[SequenceEntity]]()
        disciplines.forEach { discipline in
            let sequences = sequencesSortedByLevelNumber(discipline: discipline)
            table.append(sequences)
        }

        return table
    }

    /// Retourne les séquences associées à cette compétence sous forme d'un
    /// dictionnaire de dictionnaires ordonné par discipline et niveau. [Discipline : [ Niveau de classe : Sequences ] ].
    ///
    /// - Note: Les séquences retournées sont toutes disciplines et tous niveaux de classe confondus.
    ///
    /// Ordre de classement dans les dictionnaires:
    ///   1. Discipline
    ///   2. Niveau de classe
    ///   3. Numéro de séquence
    func sequencesPerDiscipleSortedByDisciplineNumber() -> DicoSequencesPerDisciplineLevel {
        // toutes les séquences
        let allSequences = allSequencesSortedByDisciplineLevelNumber

        // Creates a new dictionary whose keys are the groupings returned by the given closure
        // and whose values are arrays of the elements that returned each key
        let dicoOfSequencesArraysByDiscipline = OrderedDictionary(
            grouping: allSequences,
            by: { $0.program!.disciplineEnum }
        )

        var result = DicoSequencesPerDisciplineLevel()
        for (discipline, sequences) in dicoOfSequencesArraysByDiscipline {
            let dicoOfSequencesArraysByLevel = OrderedDictionary(
                grouping: sequences,
                by: { $0.program!.levelEnum }
            )
            result[discipline] = dicoOfSequencesArraysByLevel
        }

        return result
    }

    // MARK: - Gestion de la BDD

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

    /// Toutes les Coméptences travaillées du socle triées par Acronym.
    static func allSortedbyAcronym() -> [WCompEntity] {
        all().sorted(by: \.viewAcronym)
    }

    static func workedCompetency(withAcronym: String) -> WCompEntity? {
        all().filter { wComp in
            wComp.viewAcronym == withAcronym
        }.first
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
            if comp.masteryDefinitions == nil || comp.masteryDefinitions!.isEmpty {
                if tryToRepair {
                    comp.setMasteryDefinitions(MasteryLevelDictionary())
                } else {
                    errorList.append(DataBaseError.outOfBound(
                        entity: Self.entity().name!,
                        name: comp.description,
                        attribute: "masteryDefinitions",
                        id: comp.id
                    ))
                }
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

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
        setMasteryDefinitions(MasteryLevelDictionary())
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
           Niveaux de maîtrise: \(String(describing: masteryDefinitions)).withPrefixedSplittedLines("     ")
        """
        //           Compétences disciplinaires : \(String(describing: disciplineCompetencies).withPrefixedSplittedLines("     "))
    }
}
