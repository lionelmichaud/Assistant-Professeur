//
//  DateIntervalSeances.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/07/2023.
//

import EventKit
import Foundation
import SwiftUI

/// Proxy vers DateIntervalSeances
/// Refer to : [Calling Mutating Async Functions from SwiftUI Views](https://diegolavalle.com/posts/2022-11-29-calling-mutating-async-functions/)
@MainActor
extension Binding where Value == SeancesInDateInterval {
    func loadSeancesFromCalendar(
        forDiscipline discipline: Discipline,
        forClasse classe: String,
        schoolName: String,
        during period: DateInterval
    ) async {
        await wrappedValue.loadSeancesFromCalendar(
            forDiscipline: discipline,
            forClasseName: classe,
            schoolName: schoolName,
            during: period
        )
    }
}

/// Un cours et son contenu en activités pédagogique.
/// Plusieurs activités peuvent être abordées pendant le même cours.
struct Seance: Identifiable {
    var id = UUID()
    /// Acronym de la classe concernée par la séance
    var classeName: String?
    /// Evénement correspondant à la séance
    var event: EKEvent
    /// Activité pédagogique menée pendant la séance
    var activities = [ActivityEntity]()
}

/// Suite de séances (cours) pour une classe donnée et sur un horizon de temps donné.
/// Recherche dans l'App Calendar les séances à venir d'une classe.
/// - Warning: A utiliser avec le proxy ci-dessus
///
/// Refer to : [Calling Mutating Async Functions from SwiftUI Views](https://diegolavalle.com/posts/2022-11-29-calling-mutating-async-functions/)
struct SeancesInDateInterval {
    // MARK: - Properties

    /// Séances de la période
    private(set) var seances: [Seance]

    // MARK: - Initializers

    /// Initiialize une suite de séances vide (ne contenant aucune séance)
    init() {
        self.seances = [Seance]()
    }

    /// Initiialize une suite de séances avec pour contenu initial les `seances`.
    init(from seances: [Seance]) {
        self.seances = seances
    }

    // MARK: - Subscript

    subscript(idx: Int) -> Seance {
        get {
            self.seances[idx]
        }
        set {
            self.seances[idx] = newValue
        }
    }

    // MARK: - Methods

    /// Charge depsui l'App Calendar toutes les séance de la `period` pour les
    /// `discipline`, `classe` et `schoolName`.
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: La classe recherchée.
    ///   - schoolName: L'école recherchée.
    ///   - period: Intervalle de temps de recherche.
    mutating func loadSeancesFromCalendar(
        forDiscipline discipline: Discipline,
        forClasseName classe: String,
        schoolName: String,
        during period: DateInterval
    ) async {
        self.seances = await EventManager.getAllSeances(
            forDiscipline: discipline,
            forClasseName: classe,
            inCalendarNamed: schoolName,
            during: period
        ).map { event in
            Seance(classeName: classe, event: event)
        }
    }

    func print() {
        Swift.print(self.seances)
    }
}
