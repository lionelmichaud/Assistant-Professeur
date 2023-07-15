//
//  Sequence+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/01/2023.
//

import CoreData
import SwiftUI

/// Une séquence d'un programme scolaire pour une dscipline et un niveau donnés
extension SequenceEntity {
    // MARK: - Computed properties

    /// Wrapper of `name`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
            try? Self.saveIfContextHasChanged()
        }
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

    /// Nombre d'Activités dans la Séquence
    var nbOfActivities: Int {
        Int(activitiesCount)
    }
}

// MARK: - Extension Core Data

extension SequenceEntity {
    // MARK: - Gestion du temps

    /// Somme des durées des activités
    /// sans marge à la fin de la séquence
    var durationWithoutMargin: Double {
        allActivities.reduce(0) { $0 + $1.duration }
    }

    var durationWithoutMarginString: String {
        let remainder = durationWithoutMargin.remainder(dividingBy: 1.0)
        return self.durationWithoutMargin
            .formatted(.number.precision(.fractionLength(remainder == 0.0 ? 0 : 1)))
    }

    /// Somme des durées des activités en nombre de séances
    /// + une marge d'une séance à la fin de la séquence
    var durationWithMargin: Double {
        durationWithoutMargin + Double(UserPrefEntity.shared.viewMargeInterSequence)
    }

    var durationWithMarginString: String {
        let remainder = durationWithMargin.remainder(dividingBy: 1.0)
        return self.durationWithMargin
            .formatted(.number.precision(.fractionLength(remainder == 0.0 ? 0 : 1)))
    }

    // MARK: - Activités pédagogiques associées

    /// Liste des activités de la séquence non triées
    var allActivities: [ActivityEntity] {
        if let activities {
            return (activities.allObjects as! [ActivityEntity])
        } else {
            return []
        }
    }

    /// Liste des activités de la Séquence triées par numéro d'activité
    var activitiesSortedByNumber: [ActivityEntity] {
        let sortComparators =
            [
                SortDescriptor(\ActivityEntity.number, order: .forward)
            ]
        return allActivities.sorted(using: sortComparators)
    }

    /// Liste des activités de la Séquence filtrées et triées par numéro d'activité
    func filteredActivitiesSortedByNumber(
        searchString: String
    ) -> [ActivityEntity] {
        guard searchString.isNotEmpty else {
            return activitiesSortedByNumber
        }

        let sortComparators =
            [
                SortDescriptor(\ActivityEntity.number, order: .forward)
            ]
        return allActivities
            .filter { activity in
                let string = searchString.lowercased()
                return activity.name!.lowercased().contains(string)
            }
            .sorted(using: sortComparators)
    }

    // MARK: - Compétences Disciplinaires associées

    /// Liste des Compétences Disciplinaires triées par Acronym
    var disciplineCompSortedByAcronym: [DCompEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \DCompEntity.viewAcronym,
                    order: .forward
                )
            ]
        let withDuplicatesRemoved =
            Array(Set(activitiesSortedByNumber
                    .flatMap { activity in
                        activity.allDisciplineCompetencies
                    }))
        return withDuplicatesRemoved
            .sorted(using: sortComparators)
    }

    // MARK: - Connaissances Travaillées du socle associées

    /// Liste des Compétences du socle Travaillées triées par Acronym
    var workedCompSortedByAcronym: [WCompEntity] {
        let sortComparators =
            [
                SortDescriptor(
                    \WCompEntity.viewAcronym,
                    order: .forward
                )
            ]
        let wComp =
            disciplineCompSortedByAcronym
                .flatMap { dComp in
                    dComp.allWorkedCompetencies
                }
        let withDuplicatesRemoved = Array(Set(wComp))
        return withDuplicatesRemoved
            .sorted(using: sortComparators)
    }

    // MARK: - Documents associés

    /// Nombre de documents liés à l'activité
    var nbOfDocuments: Int {
        Int(self.documentCount)
    }

    /// Liste des documents importants non triées
    var allDocuments: [DocumentEntity] {
        if let documents {
            return (documents.allObjects as! [DocumentEntity])
        } else {
            return []
        }
    }

    /// Liste des documents importants triées par ordre alphabétique
    var documentsSortedByName: [DocumentEntity] {
        let sortComparators =
            [
                SortDescriptor(\DocumentEntity.docName, order: .forward)
            ]
        return allDocuments.sorted(using: sortComparators)
    }

    // MARK: - Gestion de la BDD

    /// Retourne l'état d'avancement de la progression d'une `classe` pour cette Séquence
    func statusFor(classe: ClasseEntity) -> ProgressState {
        let seqProgresses = classe.allProgresses.filter { progress in
            progress.activity?.sequence == self
        }

        guard seqProgresses.isNotEmpty else {
            return .notStarted
        }

        if seqProgresses.allSatisfy({ progress in
            // toutes les progressions pour cette séquence et cette classe sont .notStarted
            progress.status == .notStarted

        }) {
            return .notStarted

        } else if seqProgresses.allSatisfy({ $0.status == .completed }) {
            // toutes les progressions pour cette séquence et cette classe sont .completed
            return .completed

        } else if seqProgresses.contains(where: { $0.status == .inProgress }) {
            // une progression pour cette séquence et cette classe est .inProgress
            return .inProgress

        } else if seqProgresses.contains(where: { $0.status == .completed }) &&
            seqProgresses.contains(where: { $0.status == .notStarted }) {
            // une progression pour cette séquence et cette classe est .completed
            // et une autre est .notStarted
            return .inProgress

        } else if seqProgresses.contains(where: { $0.status == .invalid }) {
            // une progression pour cette séquence et cette classe est .invalid
            #if DEBUG
                print("Séquence \(self.viewNumber) pour classe \(classe.displayString): Invalide")
            #endif
            return .invalid

        } else {
            #if DEBUG
                print("Séquence \(self.viewNumber) pour classe \(classe.displayString): Invalide")
            #endif
            return .invalid
        }
    }

    /// Retourne toutes les séquences triées satisfaisant au critères:
    /// `discipline`, `cycle`, `level`
    ///
    /// Ordre de tri:
    ///   1. Discipline
    ///   2. Niveau de classe
    ///   3. Numéro de séquence
    static func allSortedByDisciplineLevelNumber(
        discipline: Discipline? = nil,
        cycle: Cycle? = nil,
        level: LevelClasse? = nil
    ) -> [SequenceEntity] {
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
        return all()
            .filter { sequence in
                var result = true

                if let discipline {
                    result =
                        result &&
                        sequence.program?.viewDisciplineEnum == discipline
                }

                if let cycle {
                    if let level = sequence.program?.viewLevelEnum {
                        result =
                            result &&
                            cycle.associatedLevels.contains(level)
                    } else {
                        result = false
                    }
                }

                if let level {
                    result =
                        result &&
                        sequence.program?.viewLevelEnum == level
                }
                return result
            }
            .sorted(using: sortComparators)
    }

    /// Créer une nouvelle instance **SANS** la sauvegarder dans le context
    static func createWithoutSaving(
        name: String = "",
        annotation: String = "",
        url: URL? = nil,
        dans program: ProgramEntity
    ) -> SequenceEntity {
        let nbSeqInProgram = program.nbOfSequences
        let sequence = SequenceEntity.create()
        // Programme d'appartenance.
        // mandatory
        sequence.program = program

        sequence.name = name
        sequence.number = Int16(nbSeqInProgram + 1)
        sequence.annotation = annotation
        sequence.url = url
        return sequence
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    @discardableResult
    static func create(
        name: String = "",
        annotation: String = "",
        url: URL? = nil,
        dans program: ProgramEntity
    ) -> SequenceEntity {
        let newSequence = createWithoutSaving(
            name: name,
            annotation: annotation,
            url: url,
            dans: program
        )

        try? Self.saveIfContextHasChanged()
        return newSequence
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { sequence in
            if sequence.program == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try sequence.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: sequence.viewName,
                            id: sequence.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: sequence.viewName,
                        id: sequence.id
                    ))
                }
            }
        }
    }

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }
}

// MARK: - Extension Debug

public extension SequenceEntity {
    override var description: String {
        """

        SEQUENCE\(program == nil ? " (ERREUR : ORPHELIN)" : ""):
           Numéro     : \(viewNumber)
           Nom        : \(String(describing: self.name))
           Annotation : \(String(describing: self.annotation))
           URL        : \(String(describing: url))
           Nb d'activités : \(activitiesCount)
           Activités  : \(String(describing: activitiesSortedByNumber).withPrefixedSplittedLines("     "))
        """
    }
}
