//
//  SchoolYearPref.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/05/2023.
//

import AppFoundation
import Foundation

struct SchoolYearPref: Codable {
    // Période de vacance
    struct Vacance: Codable, Identifiable {
        var name: String
        var interval: DateInterval
        var id: String { name }
    }

    /// Année scolaire en cours (1ère des deux années couvertes)
    static var currentSchoolYear: Int {
        if Date.now.month >= 9 {
            return Date.now.year
        } else {
            return Date.now.year - 1
        }
    }

    var calName: String = "Scolaire"

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
