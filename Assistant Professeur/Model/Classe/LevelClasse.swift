//
//  Niveau.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 14/04/2022.
//

import SwiftUI
import AppFoundation

enum LevelClasse: String, PickableEnumP, Codable {
    case n6ieme
    case n5ieme
    case n4ieme
    case n3ieme
    case n2nd
    case n1ere
    case n0terminale

    var pickerString: String {
        switch self {
            case .n6ieme:
                return "6ième"
            case .n5ieme:
                return "5ième"
            case .n4ieme:
                return "4ième"
            case .n3ieme:
                return "3ième"
            case .n2nd:
                return "2nd"
            case .n1ere:
                return "1ère"
            case .n0terminale:
                return "Terminale"
        }
    }

    var displayString: String {
        switch self {
            case .n6ieme:
                return "6E"
            case .n5ieme:
                return "5E"
            case .n4ieme:
                return "4E"
            case .n3ieme:
                return "3E"
            case .n2nd:
                return "2E"
            case .n1ere:
                return "1E"
            case .n0terminale:
                return "T"
        }
    }

    var color: Color {
        switch self {
            case .n6ieme:
                return ColorOptions.all[0]
            case .n5ieme:
                return ColorOptions.all[1]
            case .n4ieme:
                return ColorOptions.all[2]
            case .n3ieme:
                return ColorOptions.all[3]
            case .n2nd:
                return ColorOptions.all[4]
            case .n1ere:
                return ColorOptions.all[5]
            case .n0terminale:
                return ColorOptions.all[6]
        }
    }
}
