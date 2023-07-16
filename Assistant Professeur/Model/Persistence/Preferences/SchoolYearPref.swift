//
//  SchoolYearPref.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/05/2023.
//

import AppFoundation
import Foundation

/// Calendrier d'une année scolaire
struct SchoolYearPref: Codable {
    /// Une période de vacance
    struct Vacance: Codable, Identifiable {
        /// Nom de la période de vacance
        var name: String
        /// Interval de temps de la période de vacance
        var interval: DateInterval
        var id: String { name }
    }

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

    // TODO: - A mettre en préférence
    var calName: String = "Année Scolaire"

    var zone: ZoneScolaire = .ZoneC

    var interval = DateInterval(
        start: Calendar.current.date(from: currentSchoolYear.years + 9.months)!,
        end: Calendar.current.date(from: (currentSchoolYear + 1).years + 7.months + 7.days)!
    )
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
}
