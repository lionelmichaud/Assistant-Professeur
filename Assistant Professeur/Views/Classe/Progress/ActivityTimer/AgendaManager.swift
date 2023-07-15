//
//  AgendaManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 20/04/2023.
//

import AppFoundation
import SwiftUI

enum AmPm: String {
    case morning = "Matin"
    case afternoon = "Après-midi"

    static func partOfTheDay(of date: Date) -> AmPm {
        Calendar.current.component(.hour, from: date) <= 12 ?
            .morning :
            .afternoon
    }
}
