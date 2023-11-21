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
            case .all: "3 prochains mois"
        }
    }

    /// Période de recherche
    var dateInterval: DateInterval {
        var startDate: Date = .now
        var endDate: Date
        switch self {
            case .restOfTheDay:
                endDate = 1.days.from(Calendar.current.startOfDay(for: .now))!

            case .nextWeek:
                let date = 1.weeks.fromNow!
                let startOfDay = Calendar.current.startOfDay(for: date)
                let secondsInOneDay = 60 * 60 * 24.0
                endDate = startOfDay.addingTimeInterval(secondsInOneDay)

            case .all:
                endDate = 3.months.fromNow!
        }
        return DateInterval(
            start: startDate,
            end: endDate
        )
    }
}
