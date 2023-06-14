//
//  Cycle.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import AppFoundation
import Foundation

enum Cycle: String, PickableIdentifiableEnumP, Codable {
    case cycle1
    case cycle2
    case cycle3
    case cycle4
    case cycle5

    var id: String {
        rawValue
    }

    var pickerString: String {
        switch self {
            case .cycle1: return "Cycle 1"
            case .cycle2: return "Cycle 2"
            case .cycle3: return "Cycle 3"
            case .cycle4: return "Cycle 4"
            case .cycle5: return "Cycle 5"
        }
    }
}
