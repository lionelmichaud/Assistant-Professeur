//
//  SchoolYearPref.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/05/2023.
//

import AppFoundation
import Foundation
import SwiftUI

/// Une période de vacance
struct Vacance: Codable, Identifiable {
    /// Nom de la période de vacance
    var name: String
    /// Interval de temps de la période de vacance
    var interval: DateInterval
    var id: String { name }
}

/// Calendrier d'une année scolaire
struct SchoolYearPref: Codable {
    // MARK: - Type Definitions

    // MARK: - Type Properties

    /// Année scolaire en cours (1ère des deux années couvertes parl'année scolaire).
    ///
    /// Exemple: pour l'année scolaire 2023/2024 retourne 2023.
    static var currentSchoolYear: Int {
        if Date.now.month >= 9 {
            return Date.now.year
        } else {
            return Date.now.year - 1
        }
    }

    // MARK: - Properties

    /// Nom du calendrier de l'année scolaire dans l'App Calendar
    var calName: String = "Année Scolaire"
    // TODO: - A mettre en préférence

    var zone: ZoneScolaire = .ZoneC

    // MARK: - Computed Properties

    /// interval de temps de l'année scolaire entière
    var interval = DateInterval(
        start: Calendar.current.date(from: currentSchoolYear.years + 9.months)!,
        end: Calendar.current.date(from: (currentSchoolYear + 1).years + 7.months + 7.days)!
    )

    /// Périodes de vacances scolaires
    var vacances: [Vacance] = [
        Vacance(
            name: "Vacances d'automne",
            interval: DateInterval(
                start: Calendar.current.date(from: currentSchoolYear.years + 10.months + 22.days)!,
                end: Calendar.current.date(from: currentSchoolYear.years + 11.months + 6.days)!
            )
        ),
        Vacance(
            name: "Vacances de Noël",
            interval: DateInterval(
                start: Calendar.current.date(from: currentSchoolYear.years + 12.months + 17.days)!,
                end: Calendar.current.date(from: (currentSchoolYear + 1).years + 1.months + 2.days)!
            )
        ),
        Vacance(
            name: "Vacances d'hiver",
            interval: DateInterval(
                start: Calendar.current.date(from: (currentSchoolYear + 1).years + 2.months + 18.days)!,
                end: Calendar.current.date(from: (currentSchoolYear + 1).years + 3.months + 5.days)!
            )
        ),
        Vacance(
            name: "Vacances de printemps",
            interval: DateInterval(
                start: Calendar.current.date(from: (currentSchoolYear + 1).years + 4.months + 22.days)!,
                end: Calendar.current.date(from: (currentSchoolYear + 1).years + 5.months + 8.days)!
            )
        )
    ]

    // MARK: - Methods

    /// Retourne `true` si l'année scolaire inclue la `period`.
    func contains(period: DateInterval) -> Bool {
        self.interval.contains(period)
    }

    /// Retourne `true` si une période de vacance de l'année scolaire inclue la `period`.
    func vacancesContain(period: DateInterval) -> Bool {
        self.vacances.contains(where: { $0.interval.contains(period) })
    }

    /// Retourne la période de vacance de l'année scolaire incluant la `period`.
    /// Retourne `nil` sinon.
    func vacancesContaining(period: DateInterval) -> Vacance? {
        self.vacances.first(where: { $0.interval.contains(period) })
    }

    /// Retourne les périodeq de vacance de l'année scolaire incluent dans la `period`.
    /// Retourne `[]` sinon.
    func vacancesContained(in period: DateInterval) -> [Vacance] {
        self.vacances.filter({ period.contains($0.interval) })
    }
}
