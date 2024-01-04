//
//  PeriodEnum.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import AppFoundation
import Foundation

enum PeriodEnum: String, PickableEnumP {
    case restOfTheDay
    case nextWeek
    case all

    var pickerString: String {
        switch self {
            case .restOfTheDay: "Reste de la journée"
            case .nextWeek: "7 prochains jours"
            case .all: "Prochain mois"
        }
    }

    /// Période de recherche
    var dateInterval: DateInterval {
        let startDate: Date = .now
        var endDate: Date
        switch self {
            case .restOfTheDay:
                let startOfDay = Calendar.current.startOfDay(for: .now)
                endDate = 1.days.from(startOfDay)!

            case .nextWeek:
                endDate = 1.weeks.from(startDate)!

            case .all:
                endDate = 1.months.from(startDate)!
        }
        return DateInterval(
            start: startDate,
            end: endDate
        )
    }
}
