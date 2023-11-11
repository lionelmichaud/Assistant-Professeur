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

    /// Niveaux de classe associés à ce cycle d'étude
    var associatedLevels: [LevelClasse] {
        switch self {
            case .cycle1: return []
            case .cycle2: return [.nbCP, .naCE1, .n9CE2]
            case .cycle3: return [.n8CM1, .n7CM2, .n6ieme]
            case .cycle4: return [.n5ieme, .n4ieme, .n3ieme]
            case .cycle5: return [.n2nd, .n1ere, .n0terminale]
        }
    }
}
