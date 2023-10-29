//
//  PeriodEnum.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/10/2023.
//

import Foundation
import AppFoundation

enum PeriodEnum: String, PickableEnumP {
    case today
    case nextWeek
    case all

    var pickerString: String {
        switch self {
            case .today: "Aujourd'hui"
            case .nextWeek: "Semaine à venir"
            case .all: "3 prochains mois"
        }
    }
}
