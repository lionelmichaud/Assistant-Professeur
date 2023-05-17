//
//  SchoolYearPref.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/05/2023.
//

import Foundation
import AppFoundation

struct SchoolYearPref: Codable {
    static var currentSchoolYear: Int {
        if Date.now.month >= 1 {
            return Date.now.year-1
        } else {
            return Date.now.year
        }
    }

    var zone: ZoneScolaire = .ZoneC

    var interval = DateInterval(
        start: Calendar.current.date(from: currentSchoolYear.years + 9.months)!,
        end: Calendar.current.date(from: (currentSchoolYear+1).years + 7.months + 7.days)!
    )
    var autumnVacation = DateInterval(
        start: Calendar.current.date(from: currentSchoolYear.years + 10.months + 22.days)!,
        end: Calendar.current.date(from: (currentSchoolYear+1).years + 11.months + 6.days)!
    )
    var noelVacation = DateInterval(
        start: Calendar.current.date(from: currentSchoolYear.years + 12.months + 17.days)!,
        end: Calendar.current.date(from: (currentSchoolYear+1).years + 1.months + 2.days)!
    )
    var winterVacation = DateInterval(
        start: Calendar.current.date(from: (currentSchoolYear+1).years + 2.months + 18.days)!,
        end: Calendar.current.date(from: (currentSchoolYear+1).years + 3.months + 5.days)!
    )
    var paqueVacation = DateInterval(
        start: Calendar.current.date(from: (currentSchoolYear+1).years + 4.months + 22.days)!,
        end: Calendar.current.date(from: (currentSchoolYear+1).years + 5.months + 8.days)!
    )
}
