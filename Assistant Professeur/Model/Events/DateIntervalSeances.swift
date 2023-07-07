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
extension Binding where Value == DateIntervalSeances {
    func loadSeances(
        forDiscipline discipline: Discipline,
        forClasse classe: String,
        schoolName: String,
        during period: DateInterval
    ) async {
        await wrappedValue.loadSeances(
            forDiscipline: discipline,
            forClasse: classe,
            schoolName: schoolName,
            during: period
        )
    }
}

/// Recherche dans l'App Calendar les séances d'une classe
/// - Warning: A utiliser avec le proxy ci-dessus
///
/// Refer to : [Calling Mutating Async Functions from SwiftUI Views](https://diegolavalle.com/posts/2022-11-29-calling-mutating-async-functions/)
struct DateIntervalSeances {
    // MARK: - Properties

    /// Séances de la période
    private(set) var seances = [EKEvent]()

    // MARK: - Initializers

    init() {}

    // MARK: - Properties

    /// Charge toutes les séance de la `period` pour les
    /// `discipline`, `classe` et `schoolName`.
    /// - Parameters:
    ///   - discipline: La discipline recherchée.
    ///   - classe: La classe recherchée.
    ///   - schoolName: L'école recherchée.
    ///   - period: Intervalle de temps de recherche.
    mutating func loadSeances(
        forDiscipline discipline: Discipline,
        forClasse classe: String,
        schoolName: String,
        during period: DateInterval
    ) async {
        self.seances = await EventManager.getAllSeances(
            forDiscipline: discipline,
            forClasseName: classe,
            inCalendarNamed: schoolName,
            during: period
        )
    }

    func print() {
        Swift.print(self.seances)
    }
}
