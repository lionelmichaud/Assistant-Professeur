//
//  Sequence+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/01/2023.
//

import CoreData
import Foundation

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
    // MARK: - Computed properties

    /// Somme des durées des activités
    /// sans marge à la fin de la séquence
    var durationWithoutMargin: Double {
        allActivities.reduce(0) { $0 + $1.duration }
    }

    /// Somme des durées des activités en nombre de séances
    /// + une marge d'une séance à la fin de la séquence
    var durationWithMargin: Double {
        @Preference(\.margeInterSequence)
        var margeInterSequence

        return durationWithoutMargin + Double(margeInterSequence)
    }

    /// Liste des activités de la séquence non triées
    var allActivities: [ActivityEntity] {
        if let activities {
            return (activities.allObjects as! [ActivityEntity])
        } else {
            return []
        }
    }

    /// Liste des activités de la séquence triées par numéro d'activité
    var activitiesSortedByNumber: [ActivityEntity] {
        let sortComparators =
            [
                SortDescriptor(\ActivityEntity.number, order: .forward)
            ]
        return allActivities.sorted(using: sortComparators)
    }

    // MARK: - Méthodes

    /// Liste des activités de la séquence filtrées et triées par numéro d'activité
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

    func statusFor(classe: ClasseEntity) -> ProgressState {
        let progresses = classe.allProgresses

        guard progresses.isNotEmpty else {
            return .notStarted
        }

        if progresses.allSatisfy({ progress in
            progress.activity?.sequence != self ||
                progress.status == .notStarted

        }) {
            print("Séquence \(self.viewNumber) pour classe \(classe.displayString): Non commencée")
            return .notStarted

        } else if progresses.allSatisfy({ progress in
            progress.activity?.sequence != self ||
            progress.status == .completed

        }) {
            print("Séquence \(self.viewNumber) pour classe \(classe.displayString): Terminée")
            return .completed

        } else if progresses.contains(where: { progress in
            progress.activity?.sequence == self &&
            progress.status == .inProgress

        }) {
            print("Séquence \(self.viewNumber) pour classe \(classe.displayString): En cours")
            return .inProgress

        } else if progresses.contains(where: { progress in
            progress.activity?.sequence == self &&
            progress.status == .invalid

        }) {
            print("Séquence \(self.viewNumber) pour classe \(classe.displayString): Invalide")
            return .invalid

        } else {
            print("Séquence \(self.viewNumber) pour classe \(classe.displayString): Invalide")
            return .invalid
        }
    }

    // MARK: - Type Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    static func byId(id: UUID) -> Self? {
        all().first { object in
            object.id == id
        }
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

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { sequence in
            guard sequence.program != nil else {
                errorFound = true
                return
            }
        }
    }
}

// MARK: - Extension Debug

public extension SequenceEntity {
    override var description: String {
        """

        SEQUENCE:
           Numéro : \(viewNumber)
           Nom    : \(viewName)
           URL    : \(String(describing: url))
           Nb d'activités : \(activitiesCount)
           Activités : \(String(describing: allActivities).withPrefixedSplittedLines("     "))
        """
    }
}
